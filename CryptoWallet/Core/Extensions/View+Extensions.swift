import SwiftUI

extension View {
    /// Applies `transform` only when `condition` is true, without breaking
    /// the view-builder chain. Used for small conditional modifiers (e.g.
    /// disabling an animation on iOS 15) instead of duplicating whole views.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func cardShadow() -> some View {
        shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 12)
    }
}
