import Foundation
import LocalAuthentication

enum BiometricKind {
    case none
    case touchID
    case faceID
    case opticID
}

enum BiometricAuthError: LocalizedError {
    case notAvailable
    case userCancelled
    case failed
    case lockedOut

    var errorDescription: String? {
        switch self {
        case .notAvailable: return "Biometric authentication isn't set up on this device."
        case .userCancelled: return "Authentication was cancelled."
        case .failed: return "We couldn't verify it's you. Try again."
        case .lockedOut: return "Biometric authentication is locked. Use your passcode."
        }
    }
}

/// Wraps `LocalAuthentication`. Every call creates a fresh `LAContext` —
/// contexts are not meant to be reused across evaluations.
struct BiometricAuthManager {

    static var availableBiometric: BiometricKind {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        switch context.biometryType {
        case .faceID: return .faceID
        case .touchID: return .touchID
        case .opticID: return .opticID
        default: return .none
        }
    }

    /// Authenticates with biometrics, falling back to the device passcode —
    /// never a custom app-level password, per the app's security model.
    static func authenticate(reason: String) async -> Result<Void, BiometricAuthError> {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"

        var policyError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &policyError) else {
            return .failure(.notAvailable)
        }

        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            return success ? .success(()) : .failure(.failed)
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .appCancel, .systemCancel:
                return .failure(.userCancelled)
            case .biometryLockout:
                return .failure(.lockedOut)
            default:
                return .failure(.failed)
            }
        } catch {
            return .failure(.failed)
        }
    }
}
