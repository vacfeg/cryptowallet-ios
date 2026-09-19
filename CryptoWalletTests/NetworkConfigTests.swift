import XCTest
@testable import CryptoWallet

final class NetworkConfigTests: XCTestCase {
    func testEveryEVMNetworkHasAChainID() {
        for network in SupportedNetworks.evmNetworks {
            XCTAssertNotNil(network.chainID, "\(network.name) is missing a chain ID")
        }
    }

    func testEveryEVMNetworkHasAnRPCURL() {
        for network in SupportedNetworks.evmNetworks {
            XCTAssertNotNil(network.rpcURL, "\(network.name) is missing an RPC URL")
        }
    }

    func testNetworkIDsAreUnique() {
        let ids = SupportedNetworks.all.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "duplicate network id found")
    }

    func testChainIDsAreUniqueAcrossEVMNetworks() {
        let chainIDs = SupportedNetworks.evmNetworks.compactMap(\.chainID)
        XCTAssertEqual(chainIDs.count, Set(chainIDs).count, "duplicate chain id found")
    }

    func testPreviewOnlyNetworksAreNotFullySupported() {
        for network in SupportedNetworks.previewOnlyNetworks {
            XCTAssertFalse(network.kind.isFullySupported)
        }
    }

    func testEVMNetworksAreFullySupported() {
        for network in SupportedNetworks.evmNetworks {
            XCTAssertTrue(network.kind.isFullySupported)
        }
    }

    func testNetworkLookupByID() {
        XCTAssertEqual(SupportedNetworks.network(for: "ethereum")?.id, "ethereum")
        XCTAssertNil(SupportedNetworks.network(for: "not-a-real-network"))
    }

    func testDefaultTokenListAlwaysIncludesNativeAsset() {
        for network in SupportedNetworks.evmNetworks {
            let tokens = TokenList.defaultTokens(for: network)
            XCTAssertTrue(tokens.contains { $0.isNative && $0.symbol == network.symbol })
        }
    }
}
