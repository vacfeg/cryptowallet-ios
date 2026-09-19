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
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
                .fill(Theme.balanceCardGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.22), lineWidth: 1)
        )
        // A fixed soft diagonal highlight band, always visible — the
        // reference card's glossy reflection isn't subtle, it's a clear
        // bright streak across the upper third.
        .overlay(
            LinearGradient(
                colors: [.white.opacity(0.28), .white.opacity(0.05), .clear],
                startPoint: .topLeading,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: cardRadius, style: .continuous))
            .allowsHitTesting(false)
        )
        .overlay(CardSheen().clipShape(RoundedRectangle(cornerRadius: cardRadius, style: .continuous)))
        .cardShadow()
    }

    private var cardRadius: CGFloat { 32 }
}

/// A slow diagonal light streak drifting across the card — the glossy
/// "reflection" real premium fintech cards have, driven by
/// `TimelineView(.animation)` so it never glitches on reappear.
private struct CardSheen: View {
    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let progress = (sin(t * 0.35) + 1) / 2 // 0...1, slow breathing sweep

            GeometryReader { geo in
                LinearGradient(
                    colors: [.clear, .white.opacity(0.14), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: geo.size.width * 0.6)
                .rotationEffect(.degrees(20))
                .offset(x: -geo.size.width * 0.3 + progress * geo.size.width * 1.1)
                .blendMode(.plusLighter)
            }
        }
        .allowsHitTesting(false)
    }
}
