import Foundation

enum Screen {
    case splash
    case wallet(WalletViewModel)
    case connect(ConnectViewModel)
}
