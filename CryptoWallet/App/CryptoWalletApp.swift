import SwiftUI

@main
struct CryptoWalletApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(appState.settings.appearance.colorScheme)
                .onChange(of: appState.scenePhase) { phase in
                    appState.handleScenePhaseChange(phase)
                }
                .background(ScenePhaseObserver(scenePhase: $appState.scenePhase))
        }
    }
}

/// SwiftUI's `@Environment(\.scenePhase)` requires iOS 14+, which we support,
/// but we route it through AppState so lock-on-background logic lives in one
/// testable place instead of scattered `.onChange` handlers per screen.
private struct ScenePhaseObserver: View {
    @Environment(\.scenePhase) private var systemPhase
    @Binding var scenePhase: ScenePhase

    var body: some View {
        Color.clear
            .onChange(of: systemPhase) { newValue in
                scenePhase = newValue
            }
    }
}
