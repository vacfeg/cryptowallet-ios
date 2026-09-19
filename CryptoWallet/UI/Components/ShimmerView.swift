import SwiftUI

/// A subtle, single-pass shimmer used for skeleton loading states, in place
/// of a plain `ProgressView()` everywhere (rule 39). Deliberately gentle —
/// one soft diagonal sweep, not a flashing loop, so it never reads as
/// "broken" or web-page-ish.
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -0.3

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.25), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: phase * geo.size.width * 1.8)
                    .blendMode(.plusLighter)
                }
                .clipped()
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1.1
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

/// A skeleton placeholder shaped like an asset row, used while balances load.
struct SkeletonAssetRow: View {
    var body: some View {
        HStack(spacing: Spacing.m) {
            Circle()
                .fill(Theme.textTertiary.opacity(0.15))
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4).frame(width: 90, height: 12)
                RoundedRectangle(cornerRadius: 4).frame(width: 60, height: 10)
            }
            .foregroundStyle(Theme.textTertiary.opacity(0.15))
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                RoundedRectangle(cornerRadius: 4).frame(width: 70, height: 12)
                RoundedRectangle(cornerRadius: 4).frame(width: 50, height: 10)
            }
            .foregroundStyle(Theme.textTertiary.opacity(0.15))
        }
        .padding(.vertical, Spacing.s)
        .shimmering()
    }
}

struct SkeletonBalanceCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            RoundedRectangle(cornerRadius: 4).frame(width: 100, height: 12)
            RoundedRectangle(cornerRadius: 8).frame(width: 200, height: 40)
            RoundedRectangle(cornerRadius: 4).frame(width: 120, height: 12)
        }
        .foregroundStyle(.white.opacity(0.15))
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(elevated: true)
        .shimmering()
    }
}
