import Foundation

enum AutoLockDuration: Int, CaseIterable, Codable, Identifiable {
    case immediately = 0
    case oneMinute = 60
    case fiveMinutes = 300
    case fifteenMinutes = 900

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .immediately: return "Immediately"
        case .oneMinute: return "1 minute"
        case .fiveMinutes: return "5 minutes"
        case .fifteenMinutes: return "15 minutes"
        }
    }
}

/// Decides whether the wallet should re-lock after returning from the
/// background, based on how long it was backgrounded vs. the user's
/// configured `AutoLockDuration`. Pure logic, no UIKit/SwiftUI dependency,
/// so it's directly unit-testable.
struct AppLockManager {
    static func shouldLock(backgroundedAt: Date?, now: Date = Date(), duration: AutoLockDuration) -> Bool {
        guard let backgroundedAt else { return false }
        let elapsed = now.timeIntervalSince(backgroundedAt)
        return elapsed >= Double(duration.rawValue)
    }
}
