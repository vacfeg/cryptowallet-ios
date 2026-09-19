import Foundation

struct PricePoint: Codable, Hashable {
    let usd: Decimal
    let change24h: Decimal?
}

/// Abstracts the price data source so it can be swapped (CoinGecko today,
/// a different aggregator later) without touching any ViewModel.
protocol PriceProvider {
    /// Fetches prices for the given CoinGecko IDs in one batched call.
    /// Returns whatever subset it could get — a single failed symbol should
    /// never fail the whole batch.
    func prices(ids: [String], currency: FiatCurrency) async throws -> [String: PricePoint]
}
