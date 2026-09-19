import SwiftUI

/// Truncated address ("0x1a2b…9f3c") with a tap-to-copy icon that morphs
/// into a checkmark for a beat, plus a success haptic — the "copy address"
/// microinteraction called out in the design spec.
struct CopyableAddressView: View {
    let address: String
    var truncated: Bool = true

    @State private var didCopy = false

    var body: some View {
        Button {
            UIPasteboard.general.string = address
            HapticManager.success()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                didCopy = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation { didCopy = false }
            }
        } label: {
            HStack(spacing: Spacing.s) {
                Text(truncated ? address.truncatedAddress : address)
                    .font(Typography.monoSmall)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                copyIcon
            }
        }
        .buttonStyle(.plain)
    }

    /// `ContentTransition`/`.contentTransition(_:)` need iOS 16, and
    /// `.symbolEffect(.replace)` needs iOS 17 on top of that — each tier
    /// falls back to a plain icon swap (still animated by the outer
    /// `withAnimation` in the button action) on older iOS.
    @ViewBuilder
    private var copyIcon: some View {
        let icon = Image(systemName: didCopy ? "checkmark.circle.fill" : "doc.on.doc")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(didCopy ? Theme.success : Theme.textTertiary)

        if #available(iOS 17.0, *) {
            icon.contentTransition(.symbolEffect(.replace))
        } else if #available(iOS 16.0, *) {
            icon.contentTransition(.opacity)
        } else {
            icon
        }
    }
}

extension String {
    /// "0x1a2b3c4d..." -> "0x1a2b…9f3c"
    var truncatedAddress: String {
        guard count > 14 else { return self }
        let prefix = self.prefix(6)
        let suffix = self.suffix(4)
        return "\(prefix)…\(suffix)"
    }
}
