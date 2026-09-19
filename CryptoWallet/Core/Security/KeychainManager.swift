import Foundation
import Security

/// Thin wrapper around the Keychain Services API. This is the ONLY place in
/// the app allowed to persist secret material (seed phrases, private keys).
/// Nothing here ever touches UserDefaults, logs, or the network.
///
/// Items are stored with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` so
/// they (a) never leave the device via iCloud/iTunes backup and (b) are
/// inaccessible while the device is locked.
enum KeychainManager {

    enum KeychainError: Error {
        case unexpectedStatus(OSStatus)
        case itemNotFound
        case unexpectedData
    }

    private static let service = "com.cryptowallet.app.secure"

    /// - Parameter requireBiometry: When true, the item is protected by a
    ///   `SecAccessControl` that requires Face ID/Touch ID (or device
    ///   passcode fallback) at *read* time, backed by the Secure Enclave.
    ///   Used exclusively for seed phrase storage — every other item uses
    ///   the plain "unlocked, this device only" class.
    static func save(_ data: Data, key: String, requireBiometry: Bool = false) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        // Remove any existing item first — SecItemAdd fails on duplicates.
        SecItemDelete(query as CFDictionary)

        var newItem = query
        newItem[kSecValueData as String] = data

        if requireBiometry {
            guard let access = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .biometryCurrentSet,
                nil
            ) else {
                throw KeychainError.unexpectedStatus(errSecParam)
            }
            newItem[kSecAttrAccessControl as String] = access
        } else {
            newItem[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        }

        let status = SecItemAdd(newItem as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    static func load(key: String, prompt: String? = nil) throws -> Data {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        if let prompt {
            query[kSecUseOperationPrompt as String] = prompt
        }

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else { throw KeychainError.itemNotFound }
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
        guard let data = item as? Data else { throw KeychainError.unexpectedData }
        return data
    }

    static func exists(key: String) -> Bool {
        (try? load(key: key)) != nil
    }

    static func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    /// Wipes every secret this app has ever stored. Used only by "Reset Wallet".
    static func deleteAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }
}

/// Keys used to address items inside the Keychain. Values, never contents,
/// are safe to keep as plain constants.
enum KeychainKey {
    static func encryptedSeed(walletID: String) -> String { "seed.\(walletID)" }
    static let walletIndex = "wallet.index"
}
