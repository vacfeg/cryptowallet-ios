import SwiftUI

struct CreateWalletFlowView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = CreateWalletViewModel()
    @State private var step: Step = .intro

    private enum Step { case intro, reveal, verify, secured }

    var body: some View {
        Group {
            switch step {
            case .intro:
                SecurityExplanationView {
                    viewModel.generate(walletManager: appState.walletManager)
                    step = .reveal
                }
            case .reveal:
                RecoveryPhraseView(words: viewModel.words) {
                    step = .verify
                }
            case .verify:
                VerifyPhraseView(words: viewModel.words) {
                    viewModel.confirmBackup(walletManager: appState.walletManager)
                    viewModel.wipeMnemonic()
                    step = .secured
                }
            case .secured:
                WalletSecuredView {
                    appState.isOnboardingFlowActive = false
                }
            }
        }
        .navigationBarBackButtonHidden(step != .intro)
        .navigationBarHidden(true)
        .onAppear {
            appState.isOnboardingFlowActive = true
        }
        .onDisappear {
            // Belt-and-suspenders: if the user backs out of the flow any
            // other way, the mnemonic still gets wiped from memory.
            if step != .secured { viewModel.wipeMnemonic() }
        }
    }
}

private struct SecurityExplanationView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: Spacing.l) {
                Spacer()
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.violet)
                Text("Before we begin")
                    .font(Typography.largeTitle)
                    .foregroundStyle(Theme.textPrimary)
                VStack(alignment: .leading, spacing: Spacing.m) {
                    bullet("You'll get a 12-word recovery phrase.")
                    bullet("It's the only way to restore your wallet.")
                    bullet("Anyone with it can access your funds — never share it.")
                    bullet("We can't recover it for you if it's lost.")
                }
                .padding(Spacing.l)
                .glassSurface(elevated: true)
                .padding(.horizontal, Spacing.l)
                Spacer()
                PrimaryButton(title: "Continue", action: onContinue)
                    .padding(.horizontal, Spacing.l)
                    .padding(.bottom, Spacing.xl)
            }
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.success)
            Text(text)
                .font(Typography.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}
