import Foundation

/// A generic JSON-RPC 2.0 client (Ethereum and every EVM chain speak this
/// protocol identically over HTTP — only the endpoint URL differs).
struct JSONRPCClient {
    let endpoint: URL
    private let http = HTTPClient()

    private struct RPCRequest: Encodable {
        let jsonrpc = "2.0"
        let id = 1
        let method: String
        let params: [AnyEncodable]
    }

    private struct RPCResponse<T: Decodable>: Decodable {
        let result: T?
        let error: RPCErrorPayload?
    }

    private struct RPCErrorPayload: Decodable {
        let code: Int
        let message: String
    }

    func call<T: Decodable>(_ method: String, params: [AnyEncodable] = [], as type: T.Type) async throws -> T {
        let body = RPCRequest(method: method, params: params)
        let response: RPCResponse<T> = try await http.postJSON(endpoint, body: body, as: RPCResponse<T>.self)

        if let error = response.error {
            throw APIError.rpc(message: error.message)
        }
        guard let result = response.result else {
            throw APIError.invalidResponse
        }
        return result
    }
}

/// Type-erased `Encodable` so JSON-RPC params (a heterogeneous array of
/// strings/numbers/objects) can be built as a plain `[AnyEncodable]`.
struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T) {
        encodeClosure = { encoder in try value.encode(to: encoder) }
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
