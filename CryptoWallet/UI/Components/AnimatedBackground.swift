import SwiftUI

/// A soft blue glow from the top, fading to the dark background — the look
/// the reference design actually has (light source at the top, fading to
/// near-black by mid-screen), with a slow, gentle "breathing" pulse so it
/// reads as alive rather than a still image.
///
/// This replaces an earlier `Canvas`-based version that drew two blurred
/// drifting orbs — it rendered as blotchy, hard-edged shapes instead of a
/// smooth glow on a real device. Plain SwiftUI `RadialGradient` + `.blur`
/// is the well-tested way to do this and renders predictably.
struct AnimatedBackground: View {
    var intensity: Double = 1

    @State private var isPulsing = false

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Theme.blue.opacity(0.65 * intensity),
                    Theme.indigo.opacity(0.35 * intensity),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: isPulsing ? 520 : 440
            )

            RadialGradient(
                colors: [Theme.indigo.opacity(0.28 * intensity), Color.clear],
                center: UnitPoint(x: 0.85, y: 0.05),
                startRadius: 0,
                endRadius: isPulsing ? 260 : 220
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
