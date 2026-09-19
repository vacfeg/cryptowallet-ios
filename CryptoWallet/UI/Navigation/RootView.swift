import SwiftUI

/// Top-level flow switch: Splash -> Onboarding (no wallet yet) -> Unlock
/// (wallet exists but locked) -> Main tabs. Each state transition animates
/// with a simple cross-fade rather than a hard cut.
struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showSplash = true

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if !appState.walletManager.hasAnyWallet || appState.isOnboardingFlowActive {
                OnboardingView()
                    .transition(.opacity)
            } else if appState.settings.faceIDEnabled, !appState.walletManager.isUnlocked {
                UnlockView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showSplash)
        .animation(.easeInOut(duration: 0.35), value: appState.walletManager.hasAnyWallet)
        .animation(.easeInOut(duration: 0.35), value: appState.walletManager.isUnlocked)
        .task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            showSplash = false
        }
    }
}
