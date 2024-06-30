import Foundation
import Security

protocol KeychainService {
    func create<T: Codable>(key: String, value: T) throws
    func read<T: Codable>(key: String) throws -> T?
    func update<T: Codable>(key: String, value: T) throws
    func delete(key: String) throws
}


class KeychainServiceImpl: KeychainService {

    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    func create<T: Codable>(key: String, value: T) throws {
        guard let utf8EncodedKey = key.data(using: .utf8) else {
            throw KeychainServiceError.encodingKeyError
        }
        let data = try jsonEncoder.encode(value)
        // Set attributes
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: AppConstants.appIdentifier,
            kSecAttrAccount as String: utf8EncodedKey,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainServiceError.creatingError }
    }

    func read<T: Codable>(key: String) throws -> T? {
        guard let utf8EncodedKey = key.data(using: .utf8) else {
            throw KeychainServiceError.encodingKeyError
        }
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: AppConstants.appIdentifier,
                                    kSecAttrAccount as String: utf8EncodedKey,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        SecItemCopyMatching(query as CFDictionary, &item)
        guard let value = item as? Data else { return nil }
        return try jsonDecoder.decode(T.self, from: value)
    }

    func update<T: Codable>(key: String, value: T) throws {
        guard let utf8EncodedKey = key.data(using: .utf8) else {
            throw KeychainServiceError.encodingKeyError
        }
        let data = try jsonEncoder.encode(value)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: AppConstants.appIdentifier,
            kSecAttrAccount as String: utf8EncodedKey
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else { throw KeychainServiceError.updatingError }
    }

    func delete(key: String) throws {
        guard let utf8EncodedKey = key.data(using: .utf8) else {
            throw KeychainServiceError.encodingKeyError
        }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: AppConstants.appIdentifier,
            kSecAttrAccount as String: utf8EncodedKey
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { throw KeychainServiceError.deletingError }
    }
}
