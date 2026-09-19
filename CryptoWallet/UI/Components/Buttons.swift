import SwiftUI

/// The app's filled, gradient CTA button — "Create Wallet", "Send", "Review
/// transaction". Scales down slightly on press for tactile feedback and
/// fires a light haptic, instead of using a bare `Button` with default
/// styling.
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            HapticManager.tap()
            action()
        } label: {
            HStack(spacing: Spacing.s) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(Typography.buttonLabel)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: Radius.medium, style: .continuous)
                    .fill(Theme.brandGradient)
                    .opacity(isDisabled ? 0.4 : 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.medium, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(PressReportingButtonStyle(isPressed: $isPressed))
        .disabled(isDisabled || isLoading)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
    }
}

/// The secondary, glass-surfaced button — "Import Wallet", "Cancel".
struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    var isDisabled: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            HapticManager.tap()
            action()
        } label: {
            HStack(spacing: Spacing.s) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(Typography.buttonLabel)
            }
            .foregroundStyle(Theme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .glassSurface(cornerRadius: Radius.medium)
            .opacity(isDisabled ? 0.4 : 1)
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(PressReportingButtonStyle(isPressed: $isPressed))
        .disabled(isDisabled)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
    }
}

/// A compact circular action button used for Send / Receive / Swap on the
/// dashboard balance card.
struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.tap()
            action()
        } label: {
            VStack(spacing: Spacing.xs) {
                // Solid white, not a faint translucent circle — needs to
                // read as a real button against the card at a glance, the
                // way the reference design's white pills do.
                Circle()
                    .fill(.white)
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(Theme.indigo)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
                Text(title)
                    .font(Typography.caption.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
}

/// Reports press state without swallowing the tap gesture, so we can drive
/// a scale animation while still using a normal `Button`.
private struct PressReportingButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}
