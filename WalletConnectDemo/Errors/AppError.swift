import Foundation

enum AppError: LocalizedError {
    case keychain(KeychainServiceError)
    case wallet(WalletConnectServiceError)

    var localizedDescription: String {
        switch self {
        case .keychain(let error): error.localizedDescription
        case .wallet(let error): error.localizedDescription
        }
    }
}
