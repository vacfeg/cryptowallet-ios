import XCTest
@testable import CryptoWallet

@MainActor
final class AddressDerivationTests: XCTestCase {
    /// The canonical BIP-39 test-vector mnemonic. Public, well-known, and
    /// used only to check derivation logic against a fixed input — never
    /// used for a real wallet.
    private let testMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

    func testEVMAddressIsWellFormed() throws {
        let manager = try makeManagerWithImportedWallet()
        guard let account = manager.account(kind: .evm) else { return XCTFail("no EVM account derived") }
        XCTAssertTrue(account.address.hasPrefix("0x"))
        XCTAssertEqual(account.address.count, 42)
    }

    func testEveryEVMNetworkSharesTheSameAddress() throws {
        let manager = try makeManagerWithImportedWallet()
        guard let account = manager.account(kind: .evm) else { return XCTFail("no EVM account derived") }
        for network in SupportedNetworks.evmNetworks {
            XCTAssertEqual(BlockchainProviderFactory.provider(for: network).isValid(address: account.address), true)
        }
    }

    func testAllFourAccountKindsAreDerived() throws {
        let manager = try makeManagerWithImportedWallet()
        for kind in NetworkKind.allCases {
            XCTAssertNotNil(manager.account(kind: kind), "missing derived account for \(kind)")
        }
    }

    func testEVMAddressValidationRejectsMalformedInput() {
        let provider = EVMProvider(network: SupportedNetworks.ethereum)
        XCTAssertFalse(provider.isValid(address: "not-an-address"))
        XCTAssertFalse(provider.isValid(address: "0x123"))
        XCTAssertTrue(provider.isValid(address: "0x0000000000000000000000000000000000dEaD"))
    }

    private func makeManagerWithImportedWallet() throws -> WalletManager {
        let manager = WalletManager(localStore: LocalStore(defaults: UserDefaults(suiteName: #file) ?? .standard))
        _ = try manager.importWallet(mnemonic: testMnemonic)
        return manager
    }
}
