import Foundation

/// Every networking failure in the app funnels into this type so the UI
/// layer can show one consistent, human message instead of leaking
/// `URLError`, JSON decode traces, or raw RPC error payloads (rule: never
/// show "Optional(...)", "nil", or "RPC Error 500" to the user).
enum APIError: LocalizedError, Equatable {
    case noConnection
    case timeout
    case invalidResponse
    case server(code: Int)
    case rpc(message: String)
    case decoding

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No connection. Check your network and try again."
        case .timeout:
            return "That took too long. Try again."
        case .invalidResponse, .decoding:
            return "Something went wrong on our end. Try again shortly."
        case .server:
            return "The service is temporarily unavailable."
        case .rpc:
            return "The network couldn't process that request."
        }
    }

    static func from(_ error: Error) -> APIError {
        if let apiError = error as? APIError { return apiError }
        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            return .noConnection
        case NSURLErrorTimedOut:
            return .timeout
        default:
            return .invalidResponse
        }
    }
}
