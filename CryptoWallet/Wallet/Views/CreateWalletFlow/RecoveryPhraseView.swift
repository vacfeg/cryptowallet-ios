import SwiftUI

struct RecoveryPhraseView: View {
    let words: [String]
    let onContinue: () -> Void

    @State private var isRevealed = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: Spacing.l) {
                VStack(spacing: Spacing.xs) {
                    Text("Your Secret Recovery Phrase")
                        .font(Typography.title)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Anyone with this phrase can access your wallet. Write it down and store it somewhere safe — never share it or type it into a website.")
                        .font(Typography.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Spacing.l)
                .padding(.top, Spacing.l)

                ZStack {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.s) {
                        ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                            HStack(spacing: Spacing.xs) {
                                Text("\(index + 1)")
                                    .font(Typography.caption)
                                    .foregroundStyle(Theme.textTertiary)
                                    .frame(width: 18, alignment: .trailing)
                                Text(word)
                                    .font(Typography.body.weight(.medium))
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                            }
                            .padding(.horizontal, Spacing.s)
                            .padding(.vertical, Spacing.s)
                            .glassSurface(cornerRadius: Radius.small)
                        }
                    }
                    .padding(Spacing.l)
                    .blur(radius: isRevealed ? 0 : 14)

                    if !isRevealed {
                        VStack(spacing: Spacing.s) {
                            Image(systemName: "eye.slash.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Theme.textSecondary)
                            Text("Tap to reveal")
                                .font(Typography.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    HapticManager.tap()
                    withAnimation(.easeInOut(duration: 0.3)) { isRevealed.toggle() }
                }
                .padding(.horizontal, Spacing.l)

                Spacer()

                PrimaryButton(title: "I've saved it", isDisabled: !isRevealed, action: onContinue)
                    .padding(.horizontal, Spacing.l)
                    .padding(.bottom, Spacing.xl)
            }
        }
    }
}
