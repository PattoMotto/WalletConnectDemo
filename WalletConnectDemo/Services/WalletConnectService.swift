import Foundation
import SwiftUI
import UIKit
import WalletConnectModal
import WalletConnectNetworking
import WalletConnectSign

protocol WalletConnectService {
    func bootstrap()
    func connect()
}

// TODO: Clean up the mock data
class WalletConnectServiceImpl: WalletConnectService {
    private var session: Session?
    @Published var accountsDetails = [AccountDetails]()
    private let chain = Chain(name: "Ethereum", id: "eip155:1")
    private var walletConnectUri: WalletConnectURI?

    private let metadata = AppMetadata(
        name: "Swift Dapp",
        description: "WalletConnect DApp sample",
        url: "https://lab.web3modal.com/dapp",
        icons: ["https://avatars.githubusercontent.com/u/37784886"],
        redirect: try! AppMetadata.Redirect(native: "wcdemo://", universal: nil)
    )

    func bootstrap() {
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

            Sign.configure(crypto: DefaultCryptoProvider())

            #if DEBUG
            Sign.instance.logger.setLogging(level: .debug)
            Networking.instance.setLogging(level: .debug)
            #endif

            walletConnectUri = try await WalletConnectModal.instance.createPairing()
            getSession()
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

    func disconnect() async -> Result<Bool, Error> {
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

            return await actor.error.map { .failure($0) } ?? .success(true)
        }
        return .success(false)
    }

    private func getSession() {
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

actor DisconnectActor {
    var error: Error?
    
    func setError(_ error: Error) {
        self.error = error
    }
}
