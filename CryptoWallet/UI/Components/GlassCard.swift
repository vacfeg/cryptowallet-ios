import SwiftUI

/// The app's single "Liquid Glass" surface primitive. Every translucent
/// card, sheet, tab bar, and floating control goes through this modifier so
/// the material language stays identical everywhere.
///
/// Built as a hand-tuned `.ultraThinMaterial` stack — a layered blur, a
/// brand tint, and a soft top highlight — rather than Apple's native iOS 26
/// `glassEffect` API. That API was deliberately left out: no Xcode version
/// available in this project's CI (or, most likely, on your machine) ships
/// an iOS 26 SDK yet, and `#available`-gating a call doesn't help — Swift
/// still has to type-check the branch against an SDK that has to actually
/// declare the symbol. Once you're building with an Xcode that has the iOS
/// 26 SDK, this is the one spot to add a `#available(iOS 26, *)` branch
/// calling `.glassEffect(...)` on top of this fallback.
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = Radius.large
    var tint: Color = Theme.glassTint
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(background)
    }

    private var background: some View {
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
