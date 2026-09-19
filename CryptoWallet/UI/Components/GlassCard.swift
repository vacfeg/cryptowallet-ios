import SwiftUI

/// The app's single "Liquid Glass" surface primitive. Every translucent
/// card, sheet, tab bar, and floating control goes through this modifier so
/// the material language stays identical everywhere.
///
/// - iOS 26+: uses Apple's native Liquid Glass API (`glassEffect`).
/// - iOS 15–25: falls back to `.ultraThinMaterial` layered with a soft
///   gradient tint, a hairline border, and a subtle top highlight, which is
///   the closest hand-built equivalent to Liquid Glass available on those
///   OS versions. Both paths share the same corner radius, tint, and border
///   opacity so switching between them is visually seamless.
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = Radius.large
    var tint: Color = Theme.glassTint
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(background)
    }

    @ViewBuilder
    private var background: some View {
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(tint)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(border)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(tint)
                LinearGradient(
                    colors: [Color.white.opacity(0.10), Color.white.opacity(0)],
                    startPoint: .top,
                    endPoint: .center
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
            .overlay(border)
        }
    }

    private var border: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(Theme.glassBorder, lineWidth: 1)
    }
}

extension View {
    /// Applies the Liquid Glass surface as a background behind this view,
    /// without changing layout — use for cards, rows, and controls.
    func glassSurface(cornerRadius: CGFloat = Radius.large, tint: Color = Theme.glassTint) -> some View {
        modifier(GlassSurfaceModifier(cornerRadius: cornerRadius, tint: tint))
    }
}

private struct GlassSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color

    func body(content: Content) -> some View {
        GlassCard(cornerRadius: cornerRadius, tint: tint) { content }
    }
}
