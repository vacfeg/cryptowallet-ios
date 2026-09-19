import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            AnimatedBackground()
                .opacity(glowOpacity)
                .ignoresSafeArea()

            VStack(spacing: Spacing.m) {
                ZStack {
                    Circle()
                        .fill(Theme.brandGradient)
                        .frame(width: 96, height: 96)
                        .blur(radius: 18)
                        .opacity(0.6)
                    Circle()
                        .fill(Theme.brandGradient)
                        .frame(width: 88, height: 88)
                    Image(systemName: "hexagon.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                Text("CryptoWallet")
                    .font(Typography.title)
                    .foregroundStyle(Theme.textPrimary)
                    .opacity(logoOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                glowOpacity = 1
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.1)) {
                logoScale = 1
                logoOpacity = 1
            }
        }
    }
}

#Preview {
    SplashView()
}
