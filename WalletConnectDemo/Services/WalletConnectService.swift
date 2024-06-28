import Foundation
import SwiftUI
import UIKit
import WalletConnectModal
import WalletConnectNetworking
import WalletConnectSign
import Web3Modal
import Combine

protocol WalletConnectService {
    var accountsDetailsPublisher: Published<[AccountDetails]>.Publisher { get }

    var isConnected: Bool { get }

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

    var isConnected: Bool { session != nil && !accountsDetails.isEmpty }

    private var session: Session?
    @Published var accountsDetails = [AccountDetails]()
    @Published var message: String?
    private let chain = Chain(name: "Ethereum", id: "eip155:1")
    private var walletConnectUri: WalletConnectURI?

    private var cancellables = Set<AnyCancellable>()

    private let metadata = AppMetadata(
        name: "Swift Dapp",
        description: "WalletConnect DApp sample",
        url: "https://lab.web3modal.com/dapp",
        icons: ["https://avatars.githubusercontent.com/u/37784886"],
        redirect: try! AppMetadata.Redirect(native: "wcdemo://", universal: nil)
    )

    func setup() {
        // TODO: Recheck the steps
        Task {
            Networking.configure(
                groupIdentifier: Constants.groupIdentifier,
                projectId: InputConfig.projectId,
                socketFactory: DefaultSocketFactory()
            )

            WalletConnectModal.configure(
                projectId: InputConfig.projectId,
                metadata: metadata
            )

            Web3Modal.configure(
                projectId: InputConfig.projectId,
                metadata: metadata,
                crypto: DefaultCryptoProvider(),
                authRequestParams: .stub(), customWallets: [
                    .init(
                        id: "swift-sample",
                        name: "Swift Sample Wallet",
                        homepage: "https://walletconnect.com/",
                        imageUrl: "https://avatars.githubusercontent.com/u/37784886?s=200&v=4",
                        order: 1,
                        mobileLink: "wcdemo://",
                        linkMode: "https://lab.web3modal.com/wallet"
                    )
                ]
            )

            Sign.configure(crypto: DefaultCryptoProvider())

#if DEBUG
            Sign.instance.logger.setLogging(level: .debug)
            Networking.instance.setLogging(level: .debug)
            Web3Modal.instance.disableAnalytics()
#endif

            getSession()
            observeToSignPublisher()
            observeSIWEPublisher()
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
    func observeToSignPublisher() {
        Sign.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.accountsDetails.removeAll()
//                router.popToRoot()
//                Task(priority: .high) { ActivityIndicatorManager.shared.stop() }
            }
            .store(in: &cancellables)

        Sign.instance.authResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] response in
                switch response.result {
                case .success(let (session, _)):
                    print("PM: ", session)
                    if session == nil {
//                        AlertPresenter.present(message: "Wallet Succesfully Authenticated", type: .success)
                    } else {
//                        self.router.dismiss()
                        self.getSession()
                    }
                    break
                case .failure(let error):
                    print(error)
//                    AlertPresenter.present(message: error.localizedDescription, type: .error)
                }
//                Task(priority: .high) { ActivityIndicatorManager.shared.stop() }
            }
            .store(in: &cancellables)

        Sign.instance.sessionResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink { response in
                print("PM: ", response)
//                Task(priority: .high) { ActivityIndicatorManager.shared.stop() }
            }
            .store(in: &cancellables)

        Sign.instance.requestExpirationPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
//                Task(priority: .high) { ActivityIndicatorManager.shared.stop() }
//                AlertPresenter.present(message: "Session Request has expired", type: .warning)
            }
            .store(in: &cancellables)
    }

    func observeSIWEPublisher() {
        Web3Modal.instance.SIWEAuthenticationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success((let message, let signature)):
                    print("PM: ", message, signature)
//                    AlertPresenter.present(message: "Authenticated with SIWE", type: .success)
//                    self.router.dismiss()
                    self?.getSession()
                case .failure(let error):
                    print(error)
//                    AlertPresenter.present(message: "\(error)", type: .warning)
                }
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

// TODO: Move to new file
struct Chain {
    let name: String
    let id: String
}

struct AccountDetails {
    let chain: String
    let methods: [String]
    let account: String
}

struct Uri {
    let absoluteString: String
    let deeplinkUri: String
}

actor DisconnectActor {
    var error: Error?
    
    func setError(_ error: Error) {
        self.error = error
    }
}
