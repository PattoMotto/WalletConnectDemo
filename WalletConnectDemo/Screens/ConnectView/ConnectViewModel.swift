import Foundation
import SwiftUI
import UIKit
import WalletConnectModal
import WalletConnectNetworking
import WalletConnectSign

enum Constants {
    static let groupIdentifier = "group.com.walletconnect.dapp"
}

class ConnectViewModel: ObservableObject {
    private let serivce: WalletConnectService
    
    init(serivce: WalletConnectService) {
        self.serivce = serivce
    }
    
    func onTapConnect() {
        serivce.connect()
    }
}
