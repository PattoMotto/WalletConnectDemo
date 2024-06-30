import Foundation
import JSONRPC
import WalletConnectSign

enum WalletConnectServiceError: LocalizedError {
    case unknown
    case cannotGenerateSignUri
    case requestExpired
    case authWithoutSession
    case socketDisconnected
    case sessionRejection(String)
    case sdkError(Error)
    case jsonRPCError(JSONRPCError)
    case authError(AuthError)

    var localizedDescription: String {
        switch self {
        case .unknown:
            return "Unknown error"
        case .cannotGenerateSignUri:
            return "Can't generate signing URI"
        case .requestExpired:
            return "Request expired"
        case .authWithoutSession:
            return "Authorized without session"
        case .socketDisconnected:
            return "Socket connection disconnected"
        case .sessionRejection(let reason):
            return reason
        case .sdkError(let error):
            return (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        case .jsonRPCError(let error):
            return error.message
        case .authError(let error):
            return error.message
        }
    }
}
