import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Spacing.l) {
                    ZStack {
                        Circle().fill(Theme.brandGradient).frame(width: 72, height: 72)
                        Image(systemName: "hexagon.fill").font(.system(size: 28, weight: .bold)).foregroundStyle(.white)
                    }
                    .padding(.top, Spacing.l)

                    Text("CryptoWallet")
                        .font(Typography.title)
                        .foregroundStyle(Theme.textPrimary)

                    Text("Version 1.0.0")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.textTertiary)

                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text("CryptoWallet is a non-custodial wallet. Your recovery phrase and private keys are generated and stored only on this device, protected by the Keychain and Face ID/Touch ID. Nothing about your wallet — balances, addresses, or keys — is ever sent to a server we control.")
                            .font(Typography.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(Spacing.l)
                    .glassSurface(elevated: true)
                }
                .padding(Spacing.l)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
