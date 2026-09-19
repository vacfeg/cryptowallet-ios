import Foundation

/// All fiat/crypto number formatting funnels through here so the UI never
/// accidentally prints "NaN", "Optional(...)", or a raw unlocalized double.
enum AmountFormatter {
    static func fiat(_ value: Decimal?, currency: FiatCurrency) -> String {
        guard let value, value.isFinite else { return "--" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "--"
    }

    static func percent(_ value: Decimal?) -> String {
        guard let value, value.isFinite else { return "--" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.positivePrefix = formatter.plusSign
        return formatter.string(from: (value / 100) as NSDecimalNumber) ?? "--"
    }

    static func token(_ value: Decimal?, symbol: String, maxFractionDigits: Int = 6) -> String {
        guard let value, value.isFinite else { return "-- \(symbol)" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.minimumFractionDigits = 0
        let amount = formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
        return "\(amount) \(symbol)"
    }

    /// Masked display for the "hide balances" privacy toggle.
    static let hidden = "••••••"
}

enum FiatCurrency: String, CaseIterable, Codable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case ars = "ARS"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .ars: return "ARS$"
        }
    }
}

extension Decimal {
    /// `Decimal` has no `.infinity`/`.nan` literals like `Double`, but
    /// division/overflow can still produce a NaN `Decimal` at runtime
    /// (exposed via `isNaN`) — this is what `AmountFormatter` guards
    /// against before formatting.
    var isFinite: Bool {
        !isNaN
    }
}
