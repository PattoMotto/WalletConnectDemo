import Foundation
import JSONRPC

enum WalletConnectServiceError: LocalizedError {
    case cannotGenerateSignUri
    case requestExpired
    case authWithoutSession
    case socketDisconnected
    case sessionRejection(String)
    case sdkError(Error)
    case jsonRPCError(JSONRPCError)

    var localizedDescription: String {
        switch self {
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
        }
    }
}
