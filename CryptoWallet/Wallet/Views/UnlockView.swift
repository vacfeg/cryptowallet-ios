import SwiftUI

struct UnlockView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isAuthenticating = false
    @State private var errorMessage: String?
    @State private var shakeTrigger = 0

    private var biometricKind: BiometricKind { BiometricAuthManager.availableBiometric }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            Theme.heroBackgroundGradient.ignoresSafeArea()

            VStack(spacing: Spacing.l) {
                Spacer()

                ZStack {
                    Circle().fill(Theme.glassTint).frame(width: 96, height: 96)
                    Image(systemName: biometricIcon)
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                }
                .modifier(ShakeEffect(animatableData: CGFloat(shakeTrigger)))

                VStack(spacing: Spacing.xs) {
                    Text("Unlock Wallet")
                        .font(Typography.title)
                        .foregroundStyle(Theme.textPrimary)
                    Text(errorMessage ?? subtitle)
                        .font(Typography.subheadline)
                        .foregroundStyle(errorMessage == nil ? Theme.textSecondary : Theme.danger)
                }

                Spacer()

                PrimaryButton(title: "Unlock with \(biometricName)", icon: biometricIcon, isLoading: isAuthenticating) {
                    Task { await authenticate() }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.bottom, Spacing.xl)
            }
        }
        .task { await authenticate() }
    }

    private var subtitle: String {
        "Use \(biometricName) or your device passcode to continue."
    }

    private var biometricName: String {
        switch biometricKind {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        case .none: return "Passcode"
        }
    }

    private var biometricIcon: String {
        switch biometricKind {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        case .none: return "lock.fill"
        }
    }

    private func authenticate() async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        errorMessage = nil
        let result = await appState.walletManager.unlockWithBiometrics()
        isAuthenticating = false

        switch result {
        case .success:
            HapticManager.success()
        case .failure(let error):
            if case .userCancelled = error { return }
            errorMessage = error.errorDescription
            HapticManager.error()
            withAnimation(.default) { shakeTrigger += 1 }
        }
    }
}

private struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 8 * sin(animatableData * .pi * 6)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
