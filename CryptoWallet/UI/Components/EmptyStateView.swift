import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (title: String, handler: () -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.m) {
            ZStack {
                Circle()
                    .fill(Theme.glassTint)
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }
            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(Typography.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text(message)
                    .font(Typography.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            if let action {
                SecondaryButton(title: action.title, action: action.handler)
                    .frame(maxWidth: 220)
                    .padding(.top, Spacing.s)
            }
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
    }
}

/// Inline, dismissible error banner — used instead of system alerts for
/// recoverable errors (a failed price refresh, a stale balance) so the rest
/// of the screen stays usable.
struct ErrorBanner: View {
    let message: String
    var retry: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.warning)
            Text(message)
                .font(Typography.caption)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            if let retry {
                Button("Retry", action: retry)
                    .font(Typography.caption.weight(.semibold))
                    .foregroundStyle(Theme.blue)
            }
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .glassSurface(cornerRadius: Radius.small)
    }
}
