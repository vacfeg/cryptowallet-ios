import SwiftUI

struct TransactionRowView: View {
    let transaction: WalletTransaction
    let network: Network

    var body: some View {
        Button {
            openExplorer()
        } label: {
            HStack(spacing: Spacing.m) {
                ZStack {
                    Circle().fill(Theme.glassTint).frame(width: 36, height: 36)
                    Image(systemName: transaction.direction == .sent ? "arrow.up.right" : "arrow.down.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(transaction.direction == .sent ? Theme.danger : Theme.success)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(transaction.direction == .sent ? "Sent" : "Received")
                        .font(Typography.body.weight(.medium))
                        .foregroundStyle(Theme.textPrimary)
                    Text(transaction.counterpartyAddress.truncatedAddress)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(transaction.direction == .sent ? "-" : "+")\(AmountFormatter.token(transaction.amount, symbol: transaction.symbol))")
                        .font(Typography.body.weight(.medium))
                        .foregroundStyle(transaction.direction == .sent ? Theme.textPrimary : Theme.success)
                    statusLabel
                }
            }
            .padding(.vertical, Spacing.s)
            .padding(.horizontal, Spacing.m)
            .glassSurface(cornerRadius: Radius.small)
        }
        .buttonStyle(.plain)
    }

    private var statusLabel: some View {
        Text(statusText)
            .font(Typography.caption)
            .foregroundStyle(statusColor)
    }

    private var statusText: String {
        switch transaction.status {
        case .pending: return "Pending"
        case .confirmed: return transaction.timestamp.formatted(date: .abbreviated, time: .omitted)
        case .failed: return "Failed"
        }
    }

    private var statusColor: Color {
        switch transaction.status {
        case .pending: return Theme.warning
        case .confirmed: return Theme.textTertiary
        case .failed: return Theme.danger
        }
    }

    private func openExplorer() {
        guard let url = network.explorerTransactionURL(hash: transaction.hash) else { return }
        UIApplication.shared.open(url)
    }
}
