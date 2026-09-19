import SwiftUI

struct VerifyPhraseView: View {
    let words: [String]
    let onVerified: () -> Void

    @State private var targetIndices: [Int] = []
    @State private var pointer = 0
    @State private var usedWords: Set<String> = []
    @State private var shuffledChoices: [String] = []
    @State private var shakeTrigger = 0
    @State private var isComplete = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: Spacing.l) {
                VStack(spacing: Spacing.xs) {
                    Text("Verify your recovery phrase")
                        .font(Typography.title)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Select the correct word for each position to confirm you saved it.")
                        .font(Typography.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Spacing.l)
                .padding(.horizontal, Spacing.l)

                if !targetIndices.isEmpty {
                    HStack(spacing: Spacing.s) {
                        ForEach(Array(targetIndices.enumerated()), id: \.offset) { i, index in
                            Text("Word #\(index + 1)")
                                .font(Typography.caption.weight(.semibold))
                                .foregroundStyle(i == pointer ? Theme.textPrimary : Theme.textTertiary)
                                .padding(.horizontal, Spacing.m)
                                .padding(.vertical, Spacing.s)
                                .glassSurface(cornerRadius: Radius.pill, tint: i == pointer ? Theme.glassTint : Theme.glassTint.opacity(0.4))
                        }
                    }
                    .modifier(ShakeAnimator(animatableData: CGFloat(shakeTrigger)))
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 84), spacing: Spacing.s)], spacing: Spacing.s) {
                    ForEach(shuffledChoices, id: \.self) { word in
                        let isUsed = usedWords.contains(word)
                        Button {
                            select(word)
                        } label: {
                            Text(word)
                                .font(Typography.body.weight(.medium))
                                .foregroundStyle(isUsed ? Theme.textTertiary : Theme.textPrimary)
                                .padding(.horizontal, Spacing.m)
                                .padding(.vertical, Spacing.s + 2)
                                .frame(maxWidth: .infinity)
                                .glassSurface(cornerRadius: Radius.pill, tint: isUsed ? Theme.glassTint.opacity(0.25) : Theme.glassTint)
                        }
                        .disabled(isUsed || isComplete)
                    }
                }
                .padding(.horizontal, Spacing.l)

                Spacer()
            }
        }
        .onAppear(perform: setUp)
    }

    private func setUp() {
        guard words.count >= 3 else { return }
        targetIndices = Array(Set((0..<words.count).shuffled().prefix(3))).sorted()
        shuffledChoices = words.shuffled()
    }

    private func select(_ word: String) {
        guard pointer < targetIndices.count else { return }
        let expected = words[targetIndices[pointer]]

        if word == expected {
            HapticManager.success()
            usedWords.insert(word)
            pointer += 1
            if pointer == targetIndices.count {
                isComplete = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onVerified()
                }
            }
        } else {
            HapticManager.error()
            withAnimation(.default) { shakeTrigger += 1 }
        }
    }
}

private struct ShakeAnimator: GeometryEffect {
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 8 * sin(animatableData * .pi * 6), y: 0))
    }
}
