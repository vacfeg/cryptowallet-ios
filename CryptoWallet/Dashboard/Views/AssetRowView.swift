import SwiftUI

struct AssetRowView: View {
    let holding: AssetHolding
    let currency: FiatCurrency
    let isHidden: Bool

    var body: some View {
        HStack(spacing: Spacing.m) {
            ZStack {
                Circle().fill(Theme.glassTint).frame(width: 40, height: 40)
                Image(systemName: holding.token.iconSystemName)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(holding.token.name)
                    .font(Typography.body.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text(isHidden ? AmountFormatter.hidden : AmountFormatter.token(holding.balance, symbol: holding.token.symbol))
                    .font(Typography.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(isHidden ? AmountFormatter.hidden : AmountFormatter.fiat(holding.valueUSD, currency: currency))
                    .font(Typography.body.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text(AmountFormatter.percent(holding.change24h))
                    .font(Typography.caption)
                    .foregroundStyle(Theme.changeColor(holding.change24h))
            }
        }
        .padding(.vertical, Spacing.s)
    }
}
