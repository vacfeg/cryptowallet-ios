import SwiftUI

struct SendSuccessView: View {
    let network: Network
    let result: BroadcastResult
    let onDone: () -> Void

    @State private var scale: CGFloat = 0.6

    var body: some View {
        VStack(spacing: Spacing.l) {
            Spacer()
            ZStack {
                Circle().fill(Theme.success.opacity(0.18)).frame(width: 110, height: 110)
                Circle().fill(Theme.success.opacity(0.28)).frame(width: 88, height: 88)
                Image(systemName: "checkmark").font(.system(size: 34, weight: .bold)).foregroundStyle(Theme.success)
            }
            .scaleEffect(scale)

            Text("Transaction sent")
                .font(Typography.largeTitle)
                .foregroundStyle(Theme.textPrimary)

            Text("Your transaction was broadcast to the \(network.name) network.")
                .font(Typography.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            if let url = network.explorerTransactionURL(hash: result.transactionHash) {
                Link(destination: url) {
                    HStack(spacing: 6) {
                        Text("View on Explorer")
                        Image(systemName: "arrow.up.right")
                    }
                    .font(Typography.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.blue)
                }
            }

            Spacer()

            PrimaryButton(title: "Done", action: onDone)
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xl)
        }
        .onAppear {
            HapticManager.success()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) { scale = 1 }
        }
    }
}
