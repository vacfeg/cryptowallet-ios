import SwiftUI

struct WalletSecuredView: View {
    let onContinue: () -> Void

    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            AnimatedBackground().ignoresSafeArea()

            VStack(spacing: Spacing.l) {
                ZStack {
                    Circle().fill(Theme.success.opacity(0.18)).frame(width: 110, height: 110)
                    Circle().fill(Theme.success.opacity(0.28)).frame(width: 88, height: 88)
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Theme.success)
                }
                .scaleEffect(scale)

                Text("Wallet secured")
                    .font(Typography.largeTitle)
                    .foregroundStyle(Theme.textPrimary)

                Text("Your wallet is ready. Keep your recovery phrase somewhere safe — you'll need it if you ever reinstall the app.")
                    .font(Typography.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)

                Spacer().frame(height: Spacing.l)

                PrimaryButton(title: "Get Started", action: onContinue)
                    .padding(.horizontal, Spacing.xl)
            }
            .opacity(opacity)
        }
        .onAppear {
            HapticManager.success()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                scale = 1
                opacity = 1
            }
        }
    }
}
