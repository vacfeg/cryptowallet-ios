import SwiftUI

enum AppearanceMode: String, Codable, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct AppSettings: Codable, Equatable {
    var appearance: AppearanceMode = .dark
    var currency: FiatCurrency = .usd
    var hideBalances: Bool = false
    var autoLock: AutoLockDuration = .immediately
    var faceIDEnabled: Bool = true
    var selectedNetworkID: String = SupportedNetworks.ethereum.id
    var notificationsEnabled: Bool = true
}
