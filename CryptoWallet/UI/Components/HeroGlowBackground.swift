import SwiftUI

/// The dashboard's "hero zone" background — a vivid blue/indigo gradient
/// panel confined to roughly the top half of the screen, cutting off into
/// the flat near-black background below, instead of one diffuse glow
/// smeared across the whole scroll view. That top/bottom split is exactly
/// what the reference design does: a rich lit panel behind the header and
/// balance card, then plain dark behind the list content.
///
/// Layers three animated elements so it reads as genuinely alive rather
/// than a still gradient:
/// 1. a large radial glow breathing in radius and opacity,
/// 2. a secondary off-center highlight drifting in a slow orbit,
/// 3. a soft diagonal light sweep crossing the whole panel.
/// All three use plain `RadialGradient`/`LinearGradient` + `withAnimation`
/// — no `Canvas` — after the earlier Canvas-based version rendered as
/// hard-edged blotches instead of a smooth glow on a real device.
struct HeroGlowBackground: View {
    /// Fraction of the available height the vivid zone occupies before
    /// fading to nothing, so it can adapt to different screen sizes.
    var heightFraction: CGFloat = 0.62

    @State private var breathe = false
    @State private var orbit = false
    @State private var sweep = false

    var body: some View {
        GeometryReader { geo in
            let zoneHeight = geo.size.height * heightFraction

            ZStack(alignment: .top) {
                // Primary glow: broad, bright, breathing slowly.
                RadialGradient(
                    colors: [
                        Color(hex: "#5B7CFF").opacity(breathe ? 0.85 : 0.65),
                        Theme.indigo.opacity(0.45),
                        Theme.background.opacity(0)
                    ],
                    center: UnitPoint(x: 0.5, y: 0.0),
                    startRadius: 0,
                    endRadius: breathe ? zoneHeight * 1.05 : zoneHeight * 0.92
                )

                // Secondary highlight: smaller, warmer/lighter, slowly
                // orbiting near the top-right so the panel doesn't look
                // like one flat radial fill.
                RadialGradient(
                    colors: [Color(hex: "#8FA6FF").opacity(0.5), Color.clear],
                    center: UnitPoint(x: orbit ? 0.82 : 0.68, y: orbit ? 0.06 : 0.14),
                    startRadius: 0,
                    endRadius: zoneHeight * 0.5
                )
                .blendMode(.plusLighter)

                // A soft diagonal sheen sweeping across the whole panel —
                // the same trick as the card's sheen, at a larger scale.
                LinearGradient(
                    colors: [.clear, .white.opacity(0.10), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: geo.size.width * 1.6)
                .rotationEffect(.degrees(18))
                .offset(x: sweep ? geo.size.width * 0.5 : -geo.size.width * 0.9)
                .blendMode(.plusLighter)
            }
            .frame(width: geo.size.width, height: zoneHeight, alignment: .top)
            .mask(
                LinearGradient(
                    colors: [.black, .black, .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
                breathe = true
            }
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                orbit = true
            }
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                sweep = true
            }
        }
    }
}
