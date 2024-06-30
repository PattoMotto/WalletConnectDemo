@testable import WalletConnectDemo

final class MockKeychainService: Spy, KeychainService {
    var mockError: KeychainServiceError?
    var mockReadData: Codable?

    func create<T: Codable>(key: String, value: T) throws {
        record()
        if let mockError {
            throw mockError
        }
    }

    func read<T: Codable>(key: String) throws -> T? {
        record()
        if let mockError {
            throw mockError
        }
        return mockReadData as? T
    }

    func update<T: Codable>(key: String, value: T) throws {
        record()
        if let mockError {
            throw mockError
        }
    }

    func delete(key: String) throws {
        record()
        if let mockError {
            throw mockError
        }
    }
}
