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
    var elevated: Bool = false
    @ViewBuilder var content: Content

    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: cornerRadius, style: .continuous) }

    var body: some View {
        content
            .background(background)
    }

    private var background: some View {
        ZStack {
            shape.fill(.ultraThinMaterial)

            // A gradient tint, not a flat fill — a single flat color over
            // blurred material reads as a plain dark blob rather than
            // glass; a two-stop diagonal ramp gives it the same sense of
            // depth every layer of this app's UI is built on.
            shape.fill(
                LinearGradient(
                    colors: [tint.opacity(0.95), tint.opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Glossy top highlight, like light grazing the top edge of a
            // real glass panel.
            LinearGradient(
                colors: [.white.opacity(0.30), .white.opacity(0.06), .clear],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.55)
            )

            // A faint inner shadow along the bottom edge, so the surface
            // reads as a raised panel rather than a flat cutout.
            LinearGradient(
                colors: [.clear, .black.opacity(0.12)],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .clipShape(shape)
        .overlay(border)
        .shadow(color: .black.opacity(elevated ? 0.30 : 0), radius: elevated ? 18 : 0, x: 0, y: elevated ? 10 : 0)
    }

    /// A gradient stroke — brighter along the top-left, fading toward the
    /// bottom-right — rather than one flat border color, so the edge
    /// itself looks like it's catching light instead of a plain outline.
    private var border: some View {
        shape.strokeBorder(
            LinearGradient(
                colors: [.white.opacity(0.45), Theme.glassBorder, .white.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 1
        )
    }
}

extension View {
    /// Applies the Liquid Glass surface as a background behind this view,
    /// without changing layout — use for cards, rows, and controls.
    /// `elevated` adds a real drop shadow for standalone floating cards
    /// (a settings group, the asset list) — leave it off for elements that
    /// already sit inside another elevated surface, so shadows don't stack.
    func glassSurface(cornerRadius: CGFloat = Radius.large, tint: Color = Theme.glassTint, elevated: Bool = false) -> some View {
        modifier(GlassSurfaceModifier(cornerRadius: cornerRadius, tint: tint, elevated: elevated))
    }
}

private struct GlassSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color
    let elevated: Bool

    func body(content: Content) -> some View {
        GlassCard(cornerRadius: cornerRadius, tint: tint, elevated: elevated) { content }
    }
}
