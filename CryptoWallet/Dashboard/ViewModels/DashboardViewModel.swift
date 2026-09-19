import Foundation
import Combine

// Not `@MainActor` — see the note on `AppState` for why.
final class DashboardViewModel: ObservableObject {
    @Published private(set) var holdings: [AssetHolding] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastUpdated: Date?

    private let balanceService = AssetBalanceService()

    var totalValueUSD: Decimal? {
        let values = holdings.compactMap(\.valueUSD)
        guard values.count == holdings.filter({ $0.token.coinGeckoID != nil }).count, !values.isEmpty else {
            return holdings.isEmpty ? nil : values.reduce(0, +)
        }
        return values.reduce(0, +)
    }

    /// Weighted 24h portfolio change — value-weighted average of each
    /// asset's own change, so a large holding's move dominates a dust
    /// balance's.
    var portfolioChange24h: Decimal? {
        let weighted = holdings.compactMap { holding -> (Decimal, Decimal)? in
            guard let value = holding.valueUSD, let change = holding.change24h else { return nil }
            return (value, change)
        }
        guard !weighted.isEmpty else { return nil }
        let totalValue = weighted.reduce(Decimal(0)) { $0 + $1.0 }
        guard totalValue > 0 else { return nil }
        let weightedSum = weighted.reduce(Decimal(0)) { $0 + ($1.0 * $1.1) }
        return weightedSum / totalValue
    }

    func load(account: WalletAccount?, network: Network, currency: FiatCurrency) async {
        guard let account else { holdings = []; return }
        isLoading = true
        errorMessage = nil
        holdings = await balanceService.holdings(for: account, network: network, currency: currency)
        lastUpdated = Date()
        isLoading = false
    }

    func refresh(account: WalletAccount?, network: Network, currency: FiatCurrency) async {
        await load(account: account, network: network, currency: currency)
    }
}
