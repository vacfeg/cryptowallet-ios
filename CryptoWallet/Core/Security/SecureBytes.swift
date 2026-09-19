import Foundation

/// Holds sensitive bytes (a mnemonic, a derived seed) for the shortest
/// possible lifetime and overwrites its backing memory when it goes away,
/// instead of waiting on ARC + the allocator to reuse the page eventually.
///
/// This is best-effort, not a hardware guarantee — Swift `Data`/`String`
/// values copied out of this class before it deinits are NOT wiped. Callers
/// must avoid holding a separate reference to the plaintext (e.g. storing a
/// mnemonic `String` in a View's `@State`) any longer than the screen that
/// displays it needs it for.
final class SecureBytes {
    private(set) var bytes: [UInt8]

    init(_ bytes: [UInt8]) {
        self.bytes = bytes
    }

    init(string: String) {
        self.bytes = Array(string.utf8)
    }

    var string: String {
        String(decoding: bytes, as: UTF8.self)
    }

    /// Overwrites the buffer with zeros. Called automatically on deinit, but
    /// exposed so a view can wipe a mnemonic the instant the user finishes
    /// the verification step, without waiting for deallocation.
    func wipe() {
        for i in bytes.indices {
            bytes[i] = 0
        }
        bytes.removeAll()
    }

    deinit {
        wipe()
    }
}
