import Foundation

/// Reads optional API keys/RPC overrides injected at build time from
/// `Config/Secrets.xcconfig` into Info.plist (`APIConfig` dictionary — see
/// project.yml). Every value is optional; the app works on public defaults
/// without any of them configured.
enum AppConfig {
    private static let apiConfig = Bundle.main.object(forInfoDictionaryKey: "APIConfig") as? [String: String]

    static var coinGeckoAPIKey: String? { nonEmpty("CoinGeckoAPIKey") }
    static var explorerAPIKey: String? { nonEmpty("ExplorerAPIKey") }
    static var ethereumRPCOverride: URL? { url("EthereumRPCURL") }
    static var polygonRPCOverride: URL? { url("PolygonRPCURL") }

    private static func nonEmpty(_ key: String) -> String? {
        guard let value = apiConfig?[key], !value.isEmpty, !value.hasPrefix("$(") else { return nil }
        return value
    }

    private static func url(_ key: String) -> URL? {
        guard let value = nonEmpty(key) else { return nil }
        return URL(string: value)
    }
}
