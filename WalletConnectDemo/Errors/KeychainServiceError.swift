import Foundation

enum KeychainServiceError: LocalizedError {
    case creatingError
    case encodingKeyError
    case readingError
    case updatingError
    case deletingError

    var localizedDescription: String {
        switch self {
        case .creatingError:
            return "Can't delete on keychain"
        case .encodingKeyError:
            return "Can't encode the storing key"
        case .readingError:
            return "Can't delete from keychain"
        case .updatingError:
            return "Can't update from keychain"
        case .deletingError:
            return "Can't delete from keychain"
        }
    }
}
