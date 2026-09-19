import SwiftUI

/// Animates a displayed numeric string counting from its old value to a new
/// one whenever `value` changes (balance refresh, price tick), rather than
/// snapping instantly. Falls back to a plain snap if `isHidden` is set by
/// the privacy toggle — an obscured value has nothing meaningful to
/// interpolate.
struct AnimatedNumberText: View {
    let value: Decimal
    let formatter: (Decimal) -> String
    var isHidden: Bool = false
    var font: Font = Typography.balanceDisplay

    var body: some View {
        Group {
            if isHidden {
                Text(AmountFormatter.hidden)
            } else if #available(iOS 16.0, *) {
                Text(formatter(value))
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: value)
            } else {
                // iOS 15 has no `.numericText` content transition; a plain
                // opacity cross-fade is the closest equivalent available.
                Text(formatter(value))
                    .id(value)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: value)
            }
        }
        .font(font)
        .foregroundStyle(Theme.textPrimary)
    }
}
