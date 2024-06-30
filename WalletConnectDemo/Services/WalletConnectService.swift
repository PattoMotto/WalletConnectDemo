import Foundation
import SwiftUI
import UIKit
import WalletConnectModal
import WalletConnectNetworking
import WalletConnectSign
import Combine

protocol WalletConnectService {
    var accountsDetailsPublisher: Published<[AccountDetails]>.Publisher { get }
    var authResponsePublisher: Published<Result<Session, Error>?>.Publisher { get }
    var errorPublisher: Published<WalletConnectServiceError?>.Publisher { get }

    var isConnectedPublisher: Published<Bool>.Publisher { get }
    var isConnected: Bool { get }

    func setup()
    func connect()
    func disconnect() async -> Result<Bool, WalletConnectServiceError>
    func signInWithEtherium() async -> Result<Uri, WalletConnectServiceError>
    func handle(deeplink: String)
}

// TODO: Clean up the mock data
class WalletConnectServiceImpl: WalletConnectService {
    private enum Constants {
        static let personalSignKey = "personal_sign"
    }

    var accountsDetailsPublisher: Published<[AccountDetails]>.Publisher { $accountsDetails }
    var authResponsePublisher: Published<Result<WalletConnectSign.Session, any Error>?>.Publisher { $authResponse }
    var isConnectedPublisher: Published<Bool>.Publisher { $isConnected }
    var errorPublisher: Published<WalletConnectServiceError?>.Publisher { $error }

    @Published var isConnected = false
    @Published private var accountsDetails = [AccountDetails]() {
        didSet {
            isConnected = !accountsDetails.isEmpty
        }
    }
    @Published var authResponse: Result<Session, Error>?
    @Published var error: WalletConnectServiceError? {
        didSet {
            if error != nil {
                error = nil
            }
        }
    }

    private var session: Session?
    private var walletConnectURI: WalletConnectURI?
    private let metadata = AppMetadata(
        name: "WalletConnect Demo",
        description: "WalletConnect sample",
        url: "https://pattomotto.com",
        icons: ["https://avatars.githubusercontent.com/u/37784886"],
        redirect: try! AppMetadata.Redirect(native: "wcdemo://", universal: nil)
    )

    private var cancellables = Set<AnyCancellable>()

    func setup() {
        // TODO: Recheck the steps
        Task {
            Networking.configure(
                groupIdentifier: AppConstants.groupIdentifier,
                projectId: Configuration.projectId,
                socketFactory: DefaultSocketFactory()
            )

            WalletConnectModal.configure(
                projectId: Configuration.projectId,
                metadata: metadata
            )

            Sign.configure(crypto: DefaultCryptoProvider())

#if DEBUG
            Sign.instance.logger.setLogging(level: .debug)
            Networking.instance.setLogging(level: .debug)
#endif

            getSession()
            observeToSignPublisher()
            observeToWalletConnectModalPublisher()
        }
    }

    @MainActor
    func connect() {
        WalletConnectModal.set(sessionParams: .init(
            requiredNamespaces: Proposal.requiredNamespaces,
            optionalNamespaces: Proposal.optionalNamespaces
        ))
        WalletConnectModal.present(from: nil)
    }

    func disconnect() async -> Result<Bool, WalletConnectServiceError> {
        if let session {
            let actor = DisconnectActor()

            do {
                try await Sign.instance.disconnect(topic: session.topic)
                try await Sign.instance.cleanup()
            } catch {
                await actor.setError(error)
            }

            invalidateSession()

            return await actor.error.map { .failure(.sdkError($0)) } ?? .success(true)
        }
        return .success(false)
    }

    func signInWithEtherium() async -> Result<Uri, WalletConnectServiceError> {
        do {
            let uri = try await Sign.instance.authenticate(.stub(methods: [Constants.personalSignKey]))
            guard let uri else {
                return .failure(.cannotGenerateSignUri)
            }
            walletConnectURI = uri
            return .success(Uri(absoluteString: uri.absoluteString, deeplinkUri: uri.deeplinkUri))
        } catch {
            return .failure(.sdkError(error))
        }
    }

    func handle(deeplink: String) {
        do {
            try Sign.instance.dispatchEnvelope(deeplink)
        } catch {
            print(error)
        }
    }
}

// MARK: - PRIVATE
private extension WalletConnectServiceImpl {
    func invalidateSession() {
        accountsDetails.removeAll()
        session = nil
    }

    func observeToSignPublisher() {
        Sign.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.invalidateSession()
            }
            .store(in: &cancellables)

        Sign.instance.sessionRejectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _, reason in
                self.error = .sessionRejection(reason.message)
            }
            .store(in: &cancellables)

        Sign.instance.authResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] response in
                switch response.result {
                case .success(let (session, _)):
                    if let session, session.namespaces.values.contains(where: { $0.methods.contains(Constants.personalSignKey) }) {
                        self.authResponse = .success(session)

                        // Reset, never use for now.
                        self.walletConnectURI = nil
                    } else {
                        self.authResponse = .failure(WalletConnectServiceError.authWithoutSession)
                    }
                case .failure(let error):
                    self.authResponse = .failure(error)
                }
            }
            .store(in: &cancellables)

        Sign.instance.sessionResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                print("PM: sessionResponsePublisher", response)
            }
            .store(in: &cancellables)

        Sign.instance.requestExpirationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.error = .requestExpired
            }
            .store(in: &cancellables)

        Sign.instance.socketConnectionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] status in
                switch status {
                case .connected:
                    break
                case .disconnected:
                    self.error = .socketDisconnected
                }
            }
            .store(in: &cancellables)

        Sign.instance.sessionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] sessions in
                self.process(sessions: sessions)
            }
            .store(in: &cancellables)
    }

    func observeToWalletConnectModalPublisher() {
        WalletConnectModal.instance.socketConnectionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] status in
                switch status {
                case .connected:
                    break
                case .disconnected:
                    self.error = .socketDisconnected
                }
            }
            .store(in: &cancellables)

        WalletConnectModal.instance.sessionRejectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] proposal, reason in
                self.error = .sessionRejection(reason.message)
            }
            .store(in: &cancellables)

        WalletConnectModal.instance.sessionResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] response in
                switch response.result {
                case .response(let response):
                    print("PM: sessionResponsePublisher", response)
                case .error(let error):
                    self.error = .jsonRPCError(error)
                }
            }
            .store(in: &cancellables)
    }

    func getSession() {
        process(sessions: Sign.instance.getSessions())
    }

    func process(sessions: [Session]) {
        guard let session = sessions.first else { return }
        self.session = session
        session.namespaces.values.forEach { namespace in
            namespace.accounts.forEach { account in
                accountsDetails.append(
                    AccountDetails(
                        chain: account.blockchainIdentifier,
                        methods: Array(namespace.methods),
                        account: account.address
                    )
                )
            }
        }
    }
}

actor DisconnectActor {
    var error: Error?

    func setError(_ error: Error) {
        self.error = error
    }
}
