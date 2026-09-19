import SwiftUI

/// A slow, continuous animated glow — two soft blurred orbs (blue + indigo,
/// matching `Theme.brandGradient`) drifting behind the content on a gentle
/// sine path. Driven by `TimelineView(.animation)` rather than a repeating
/// `withAnimation` loop, so it can't get stuck or restart oddly when a
/// screen reappears, and it costs nothing when the view isn't visible.
///
/// Used behind Splash, Onboarding, and the dashboard header — anywhere the
/// spec asked for a "fondo animado" instead of a static gradient.
struct AnimatedBackground: View {
    var intensity: Double = 1

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate

            Canvas { canvasContext, size in
                let blueCenter = CGPoint(
                    x: size.width * (0.3 + 0.12 * sin(t * 0.12)),
                    y: size.height * (0.18 + 0.05 * cos(t * 0.10))
                )
                let indigoCenter = CGPoint(
                    x: size.width * (0.75 + 0.10 * cos(t * 0.09)),
                    y: size.height * (0.32 + 0.06 * sin(t * 0.14))
                )

                draw(orb: blueCenter, color: Theme.blue, radius: size.width * 0.55, in: &canvasContext)
                draw(orb: indigoCenter, color: Theme.indigo, radius: size.width * 0.5, in: &canvasContext)
            }
            .blur(radius: 70)
            .opacity(intensity)
        }
        .allowsHitTesting(false)
    }

    private func draw(orb center: CGPoint, color: Color, radius: CGFloat, in context: inout GraphicsContext) {
        let rect = CGRect(x: center.x - radius / 2, y: center.y - radius / 2, width: radius, height: radius)
        let gradient = Gradient(colors: [color.opacity(0.55), color.opacity(0)])
        context.fill(
            Path(ellipseIn: rect),
            with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: radius / 2)
        )
    }
}
