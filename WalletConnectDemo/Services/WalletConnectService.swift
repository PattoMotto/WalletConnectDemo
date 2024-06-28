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

class WalletConnectServiceImpl: WalletConnectService {
    private let metadata = AppMetadata(
        name: "Swift Dapp",
        description: "WalletConnect DApp sample",
        url: "https://lab.web3modal.com/dapp",
        icons: ["https://avatars.githubusercontent.com/u/37784886"],
        redirect: try! AppMetadata.Redirect(native: "wcdapp://", universal: "https://lab.web3modal.com/dapp", linkMode: true)
    )

    func bootstrap() {
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
        
        WalletConnectModal.set(sessionParams: .init(
            requiredNamespaces: Proposal.requiredNamespaces,
            optionalNamespaces: Proposal.optionalNamespaces
        ))
    }
    
    func connect() {
        WalletConnectModal.present(from: nil)
    }
}
