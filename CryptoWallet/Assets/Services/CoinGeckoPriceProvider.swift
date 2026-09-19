import Foundation

/// CoinGecko's free `/simple/price` endpoint. Works unauthenticated at a
/// lower rate limit; set `COINGECKO_API_KEY` in `Config/Secrets.xcconfig`
/// for a Demo-tier key to raise it (see `AppConfig`).
struct CoinGeckoPriceProvider: PriceProvider {
    private let http = HTTPClient()

    func prices(ids: [String], currency: FiatCurrency) async throws -> [String: PricePoint] {
        guard !ids.isEmpty else { return [:] }

        var components = URLComponents(string: "https://api.coingecko.com/api/v3/simple/price")!
        var queryItems = [
            URLQueryItem(name: "ids", value: ids.joined(separator: ",")),
            URLQueryItem(name: "vs_currencies", value: currency.rawValue.lowercased()),
            URLQueryItem(name: "include_24hr_change", value: "true")
        ]
        if let apiKey = AppConfig.coinGeckoAPIKey, !apiKey.isEmpty {
            queryItems.append(URLQueryItem(name: "x_cg_demo_api_key", value: apiKey))
        }
        components.queryItems = queryItems

        guard let url = components.url else { throw APIError.invalidResponse }

        let raw = try await http.getJSON(url, as: [String: [String: Decimal]].self)
        let currencyKey = currency.rawValue.lowercased()
        let changeKey = "\(currencyKey)_24h_change"

        var result: [String: PricePoint] = [:]
        for (id, values) in raw {
            guard let usd = values[currencyKey] else { continue }
            result[id] = PricePoint(usd: usd, change24h: values[changeKey])
        }
        return result
    }
}
