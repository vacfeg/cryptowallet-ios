import SwiftUI

// Deliberately not `@MainActor`: this class (and the view models below) are
// read from plain helper computed properties/methods all over the view
// layer, not just from inside a View's `body` — and only `body` itself is
// implicitly main-actor-isolated by the `View` protocol. Explicitly
// isolating these types would require every such helper to be annotated or
// `await`-ed too, everywhere they're used. In practice every mutation here
// already originates on the main thread (user-initiated SwiftUI actions),
// so this stays a conventional, un-isolated `ObservableObject`.
final class AppState: ObservableObject {
    @Published var walletManager: WalletManager
    @Published var settings: AppSettings {
        didSet { localStore.save(settings, key: StorageKey.appSettings) }
    }
    @Published var scenePhase: ScenePhase = .active

    /// True for the entire duration of the create/import flow, from the
    /// moment a wallet is generated (which flips `hasAnyWallet` true right
    /// away) until the user finishes reviewing/verifying it. Keeps
    /// `RootView` from jumping to the dashboard mid-flow just because a
    /// wallet now technically exists.
    @Published var isOnboardingFlowActive = false

    private var backgroundedAt: Date?
    private let localStore = LocalStore()

    init() {
        self.walletManager = WalletManager()
        self.settings = localStore.load(AppSettings.self, key: StorageKey.appSettings) ?? AppSettings()
    }

    var selectedNetwork: Network {
        SupportedNetworks.network(for: settings.selectedNetworkID) ?? SupportedNetworks.ethereum
    }

    func selectNetwork(_ network: Network) {
        settings.selectedNetworkID = network.id
    }

    /// Auto-lock on return from background, per the configured duration —
    /// runs regardless of whether Face ID is enabled, since "Immediately"
    /// is also a valid choice with Face ID off (the unlock screen then just
    /// has no biometric option and nothing to fall back to but reopening
    /// isn't blocked; Face ID gates re-entry only when enabled).
    func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            backgroundedAt = Date()
        case .active:
            if settings.faceIDEnabled, AppLockManager.shouldLock(backgroundedAt: backgroundedAt, duration: settings.autoLock) {
                walletManager.lock()
            }
            backgroundedAt = nil
        default:
            break
        }
    }
}
