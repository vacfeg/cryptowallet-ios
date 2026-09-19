import SwiftUI

struct BalanceCardView: View {
    let totalValueUSD: Decimal?
    let change24h: Decimal?
    let currency: FiatCurrency
    let isHidden: Bool
    let network: Network
    let onSend: () -> Void
    let onReceive: () -> Void
    let onSwap: () -> Void
    let onNetworkTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            topRow
            balanceRow
            changePill
            buttonsRow
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    private var topRow: some View {
        HStack {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                Text("Total Balance")
                    .font(Typography.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer()

            Button(action: onNetworkTap) {
                HStack(spacing: 6) {
                    Image(systemName: network.iconSystemName)
                        .font(.system(size: 12, weight: .semibold))
                    Text(network.symbol)
                        .font(Typography.caption.weight(.semibold))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, Spacing.s + 2)
                .padding(.vertical, 6)
                .background(Capsule().fill(.white.opacity(0.18)))
                .overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var balanceRow: some View {
        AnimatedNumberText(
            value: totalValueUSD ?? 0,
            formatter: { AmountFormatter.fiat($0, currency: currency) },
            isHidden: isHidden,
            font: Typography.balanceDisplay
        )
        .foregroundStyle(.white)
    }

    /// The nested "sub-card" pill the reference design shows below the
    /// headline figure (its "Bonus account" row) — here used for the 24h
    /// portfolio change, so the card keeps that same two-tier structure
    /// instead of a single flat number.
    private var changePill: some View {
        HStack {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                Text("24h Change")
                    .font(Typography.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            changeValue
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s + 2)
        .background(
            RoundedRectangle(cornerRadius: Radius.medium, style: .continuous)
                .fill(.white.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.medium, style: .continuous)
                .strokeBorder(.white.opacity(0.16), lineWidth: 1)
        )
    }

    private var changeValue: some View {
        Group {
            if isHidden {
                Text(AmountFormatter.hidden)
            } else if let change24h {
                HStack(spacing: 3) {
                    Image(systemName: change24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 11, weight: .bold))
                    Text(AmountFormatter.percent(change24h))
                }
            } else {
                Text("--")
            }
        }
        .font(Typography.subheadline.weight(.bold))
        .foregroundStyle((change24h ?? 0) >= 0 ? Theme.success : Theme.danger)
    }

    private var buttonsRow: some View {
        HStack(spacing: Spacing.s) {
            PillActionButton(title: "Send", icon: "arrow.up", style: .light, action: onSend)
            PillActionButton(title: "Receive", icon: "arrow.down", style: .dark, action: onReceive)
            Button(action: onSwap) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(.white.opacity(0.18)))
                    .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, Spacing.xs)
    }

    private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
                .fill(Theme.balanceCardGradient)

            // Decorative watermark icon in the corner — the visual weight
            // the reference card's outlined trophy icon adds, using the
            // app's own hexagon mark instead of borrowing imagery.
            Image(systemName: "hexagon")
                .font(.system(size: 150, weight: .thin))
                .foregroundStyle(.white.opacity(0.08))
                .rotationEffect(.degrees(-12))
                .offset(x: 90, y: 10)
                .allowsHitTesting(false)
                .clipped()

            RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.22), lineWidth: 1)

            // A fixed soft diagonal highlight band, always visible — the
            // reference card's glossy reflection isn't subtle, it's a clear
            // bright streak across the upper third.
            LinearGradient(
                colors: [.white.opacity(0.28), .white.opacity(0.05), .clear],
                startPoint: .topLeading,
                endPoint: .bottom
            )

            CardSheen()
        }
        .clipShape(RoundedRectangle(cornerRadius: cardRadius, style: .continuous))
        .allowsHitTesting(true)
        .cardShadow()
    }

    private var cardRadius: CGFloat { 32 }
}

private enum PillButtonStyle {
    case light, dark
}

/// The large split pill buttons ("Withdraw"/"+ Deposit" in the reference) —
/// an icon-and-label button that fills its share of the row, not a small
/// circle with a caption underneath.
private struct PillActionButton: View {
    let title: String
    let icon: String
    let style: PillButtonStyle
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.tap()
            action()
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                Text(title)
                    .font(Typography.subheadline.weight(.bold))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.s + 4)
            .background(Capsule().fill(background))
            .overlay(Capsule().strokeBorder(.white.opacity(style == .light ? 0 : 0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var background: AnyShapeStyle {
        switch style {
        case .light: return AnyShapeStyle(Color.white)
        case .dark: return AnyShapeStyle(Color.black.opacity(0.22))
        }
    }

    private var foreground: Color {
        switch style {
        case .light: return Theme.indigo
        case .dark: return .white
        }
    }
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
                    colors: [.clear, .white.opacity(0.16), .clear],
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
