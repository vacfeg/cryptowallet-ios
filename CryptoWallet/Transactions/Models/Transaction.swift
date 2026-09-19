import Foundation

enum TransactionDirection: String, Codable {
    case sent, received
}

enum TransactionStatus: String, Codable {
    case pending, confirmed, failed
}

struct WalletTransaction: Identifiable, Codable, Hashable {
    let hash: String
    let networkID: String
    let direction: TransactionDirection
    let status: TransactionStatus
    let counterpartyAddress: String
    let amount: Decimal
    let symbol: String
    let timestamp: Date
    let tokenContractAddress: String?

    var id: String { "\(networkID).\(hash)" }
}
