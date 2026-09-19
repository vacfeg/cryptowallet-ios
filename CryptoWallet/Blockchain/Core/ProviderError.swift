import Foundation

enum ProviderError: LocalizedError, Equatable {
    case unsupportedNetwork
    case invalidAddress
    case insufficientFunds
    case network(APIError)
    case signingFailed
    case notYetImplemented

    var errorDescription: String? {
        switch self {
        case .unsupportedNetwork:
            return "This network isn't supported yet."
        case .invalidAddress:
            return "That doesn't look like a valid address."
        case .insufficientFunds:
            return "Insufficient balance to cover the amount and network fee."
        case .network(let apiError):
            return apiError.errorDescription
        case .signingFailed:
            return "We couldn't sign that transaction."
        case .notYetImplemented:
            return "This feature isn't available for this network yet."
        }
    }
}
