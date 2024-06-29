import Foundation
import SwiftUI
import UIKit
import WalletConnectModal
import WalletConnectNetworking
import WalletConnectSign
import Combine

protocol WalletConnectService {
    var accountsDetailsPublisher: Published<[AccountDetails]>.Publisher { get }
    var accountsDetails: [AccountDetails] { get }
    
    var isConnected: Bool { get }

    var isValidSessionPublisher: Published<Bool>.Publisher { get }
    var isValidSession: Bool { get }

    func setup()
    func connect()
    func disconnect() async -> Result<Bool, WalletConnectServiceError>
    func signInWithEtherium() async -> Result<Uri, WalletConnectServiceError>
    func handle(deeplink: String)
}

enum WalletConnectServiceError: Error {
    case cannotGenerateSignUri
    case sdkError(Error)
}

// TODO: Clean up the mock data
class WalletConnectServiceImpl: WalletConnectService {
    var accountsDetailsPublisher: Published<[AccountDetails]>.Publisher { $accountsDetails }
    var isValidSessionPublisher: Published<Bool>.Publisher { $isValidSession }
    var isConnected: Bool { session != nil && !accountsDetails.isEmpty }

    @Published var isValidSession = false
    @Published var accountsDetails = [AccountDetails]()
    @Published var message: String?

    private var session: Session?
    private var walletConnectURI: WalletConnectURI?
    private let metadata = AppMetadata(
        name: "WalletConnect Demo",
        description: "WalletConnect sample",
        url: "https://lab.web3modal.com/dapp",
        icons: ["https://avatars.githubusercontent.com/u/37784886"],
        redirect: try! AppMetadata.Redirect(native: "wcdemo://", universal: nil)
    )

    private var cancellables = Set<AnyCancellable>()

    func setup() {
        // TODO: Recheck the steps
        Task {
            Networking.configure(
                groupIdentifier: Constants.groupIdentifier,
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

            Task {
                do {
                    try await Sign.instance.disconnect(topic: session.topic)
                    accountsDetails.removeAll()
                    isValidSession = false
                } catch {
                    await actor.setError(error)
                }
            }

            return await actor.error.map { .failure(.sdkError($0)) } ?? .success(true)
        }
        return .success(false)
    }

    func signInWithEtherium() async -> Result<Uri, WalletConnectServiceError> {
        do {
            let uri = try await Sign.instance.authenticate(.stub(methods: ["personal_sign"]))
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
        getSession()
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
        isValidSession = false
    }

    func observeToSignPublisher() {
        Sign.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.invalidateSession()
            }
            .store(in: &cancellables)

        Sign.instance.authResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] response in
                switch response.result {
                case .success(let (session, _)):
                    if let session {
                        print("PM: ", session)

                        self.isValidSession = true

                        // Reset, never use for now.
                        self.walletConnectURI = nil
                    }
                    break
                case .failure(let error):
                    print(error)
                }
            }
            .store(in: &cancellables)

        Sign.instance.sessionResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                print("PM: ", response)
            }
            .store(in: &cancellables)

        Sign.instance.requestExpirationPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                print("request expired")
            }
            .store(in: &cancellables)
    }

    func getSession() {
        if let session = Sign.instance.getSessions().first {
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
}

actor DisconnectActor {
    var error: Error?
    
    func setError(_ error: Error) {
        self.error = error
    }
}
