import SwiftUI

struct BalanceCardView: View {
    let totalValueUSD: Decimal?
    let change24h: Decimal?
    let currency: FiatCurrency
    let isHidden: Bool
    let onSend: () -> Void
    let onReceive: () -> Void
    let onSwap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Total Balance")
                .font(Typography.subheadline)
                .foregroundStyle(.white.opacity(0.7))

            AnimatedNumberText(
                value: totalValueUSD ?? 0,
                formatter: { AmountFormatter.fiat($0, currency: currency) },
                isHidden: isHidden,
                font: Typography.balanceDisplay
            )
            .foregroundStyle(.white)

            HStack(spacing: Spacing.xs) {
                if let change24h, !isHidden {
                    Image(systemName: change24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 12, weight: .bold))
                    Text(AmountFormatter.percent(change24h))
                } else {
                    Text("--")
                }
                Text("today")
                    .foregroundStyle(.white.opacity(0.6))
            }
            .font(Typography.caption.weight(.semibold))
            .foregroundStyle((change24h ?? 0) >= 0 ? Theme.success : Theme.danger)

            HStack(spacing: Spacing.xl) {
                QuickActionButton(title: "Send", icon: "arrow.up", action: onSend)
                QuickActionButton(title: "Receive", icon: "arrow.down", action: onReceive)
                QuickActionButton(title: "Swap", icon: "arrow.left.arrow.right", action: onSwap)
            }
            .padding(.top, Spacing.s)
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.large, style: .continuous)
                .fill(Theme.balanceCardGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.large, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        )
        .overlay(
            LinearGradient(colors: [.white.opacity(0.08), .clear], startPoint: .top, endPoint: .center)
                .clipShape(RoundedRectangle(cornerRadius: Radius.large, style: .continuous))
                .allowsHitTesting(false)
        )
        .cardShadow()
    }
}
