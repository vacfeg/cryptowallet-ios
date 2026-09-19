import Foundation

/// Generic `UserDefaults`-backed store for NON-SECRET data only: app
/// preferences, cached prices, and public wallet metadata (addresses,
/// nicknames). Anything secret (seed phrases, private keys) belongs in
/// `KeychainManager`, never here — see AGENTS section on seed security.
struct LocalStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func remove(key: String) {
        defaults.removeObject(forKey: key)
    }
}

enum StorageKey {
    static let appSettings = "settings.app"
    static let walletAccounts = "wallet.accounts"
    static let selectedNetwork = "wallet.selectedNetwork"
    static let priceCache = "prices.cache"
    static let customTokens = "assets.customTokens"
}
