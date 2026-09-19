# CryptoWallet — a real, non-custodial iOS wallet

A native SwiftUI crypto wallet: BIP-39 seed generation, Keychain + Face ID/Touch ID
protected key storage, real on-chain balances and transaction signing on Ethereum
and six other EVM networks, QR send/receive, and a multi-chain architecture ready
to grow into Bitcoin/Solana/Tron. iOS 15+.

**Important — how this project was built:** it was written and organized without
access to Xcode or a Mac (no compiler was available to verify it). Every file was
written carefully and the architecture is real, but **you must build it once on
Xcode (locally or via the included CI workflow) and fix whatever the compiler
flags** before treating it as done — see [What to verify on first build](#what-to-verify-on-first-build)
below for the specific spots most likely to need a small fix, and why.

---

## 1. What's real vs. what's a stub

Per the "don't fake it" rule this project was built against, here is the exact
state of every feature:

| Feature | Status |
|---|---|
| BIP-39 seed generation (CSPRNG, real entropy) | **Real** — via WalletCore, not `random()`/`UUID` |
| Seed phrase import + checksum validation | **Real** |
| HD key derivation (BIP-32/44) | **Real** — via WalletCore |
| Keychain storage, Face ID/Touch ID gated | **Real** — `SecAccessControl(.biometryCurrentSet)` |
| Ethereum, Base, Arbitrum, Optimism, Polygon, BNB Chain, Avalanche C-Chain | **Real** — live RPC balances, real signing, real broadcast |
| ERC-20 token balances/transfers | **Real** — hand-encoded ABI calls |
| Transaction history | **Real** — Etherscan V2 unified API (needs a free API key) |
| Prices (USD/EUR/ARS, 24h change) | **Real** — CoinGecko, with offline cache fallback |
| QR scan / QR generate | **Real** — native AVFoundation + CoreImage |
| Bitcoin, Solana, Tron | **Address derivation only.** Real addresses, but no balance/send — see below |
| Swap | **UI shell only**, explicitly not wired to a fake transaction — see `SwapProvider` note below |
| Push notifications | Toggle exists; no backend/polling service implemented |

### Why Bitcoin/Solana/Tron are address-only

These three need a fundamentally different transaction model than the EVM
account/nonce model this version implements (UTXOs for Bitcoin, a different
account/rent model and recent-blockhash signing for Solana, a bandwidth/energy
resource model for Tron) — building that correctly is a second version's worth of
work. The architecture is already shaped for it: `BlockchainProvider` is a
protocol (`Blockchain/Core/BlockchainProvider.swift`), and
`Blockchain/Bitcoin/`, `Blockchain/Solana/`, `Blockchain/Tron/` each already have
a real provider file deriving real addresses via WalletCore — they just throw
`ProviderError.notYetImplemented` for balance/send instead of inventing numbers.
`BlockchainProviderFactory` is the one place to wire in a real implementation
later.

### Why Swap is a shell

Swapping needs a liquidity aggregator (0x, 1inch, LiFi, etc.) with its own API
key and quote/slippage logic. Rather than fake a transaction, `DashboardView`'s
Swap sheet is a real, reachable, styled screen that says so — see
`SwapPlaceholderView` in `Dashboard/Views/DashboardView.swift`. Add a
`SwapProvider` protocol next to `PriceProvider`/`TransactionProvider` when
you're ready to wire one in.

---

## 2. Providers and RPC endpoints used

All swappable via protocols (`BlockchainProvider`, `PriceProvider`,
`TransactionProvider`) — nothing is hardcoded into the UI layer.

- **RPC (EVM balances/sending):** public, free endpoints per network, defined in
  `Blockchain/Core/SupportedNetworks.swift` (e.g. PublicNode for Ethereum,
  `polygon-rpc.com`, `arb1.arbitrum.io`, official Base/Optimism/Avalanche RPCs,
  Binance's public BSC endpoint). No key required. Override any of them with
  your own Infura/Alchemy URL via `Secrets.xcconfig`.
- **Prices:** [CoinGecko](https://www.coingecko.com/en/api) `/simple/price`,
  works unauthenticated at a lower rate limit. Add a free Demo API key to raise it.
- **Transaction history:** [Etherscan's V2 unified API](https://docs.etherscan.io/etherscan-v2)
  — one API key covers Ethereum and every other network in this app
  (Basescan, Arbiscan, Polygonscan, BscScan, Snowtrace, Optimism's explorer)
  through a single endpoint keyed by `chainid`. **Required** for the Activity
  tab and per-asset transaction history to work — without a key, those screens
  show their normal "couldn't load" empty state rather than crashing.

### Configuring API keys

```bash
cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig
```

Edit `Config/Secrets.xcconfig` and fill in what you have — every key is
optional except `EXPLORER_API_KEY` (needed only for transaction history).
This file is gitignored; it never gets committed. See the comments in
`Secrets.xcconfig.example` for where to get each key.

---

## 3. Project structure

```
CryptoWallet/
  App/            App entry point, global AppState
  Core/           Security (Keychain/Face ID), networking, storage, extensions
  Blockchain/      Core protocols + per-chain adapters (EVM/, Bitcoin/, Solana/, Tron/)
  Wallet/         HD wallet, BIP-39, account derivation, onboarding flows
  Assets/         Token models, balance + price services
  Transactions/   Transaction models, explorer API
  Dashboard/      Home tab, balance card, asset list, asset detail
  Send/           Send flow (amount -> review -> confirm -> broadcast)
  Receive/        Receive screen, QR generation
  Scanner/        QR scanning (AVFoundation)
  Networks/       Network switcher
  Activity/       Transaction history tab
  Settings/       Security, appearance, currency, assets, about
  UI/             Theme, reusable glass components, navigation shell
  Resources/      Assets.xcassets, generated Info.plist
CryptoWalletTests/  BIP-39, address derivation, formatting, network-config tests
```

No `ContentView.swift` grab-bag — every screen lives under its feature folder,
per the architecture the app was scoped against.

---

## 4. Running it in Xcode (if you have a Mac)

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`) —
   the `.xcodeproj` is generated from `project.yml`, not committed, so it's
   never stale or full of merge conflicts. `project.yml` pins
   `options.projectFormat: xcode15_3` so the generated project stays
   openable on Xcode 15.x too, not just whatever's newest — if you're on
   Xcode 16+ this doesn't affect you either way.
2. `cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig` (fill in keys, optional).
3. `xcodegen generate`
4. Open `CryptoWallet.xcodeproj`, select the `CryptoWallet` scheme, pick a
   simulator or your device, and run.
5. Run the tests (`Cmd+U`) — `CryptoWalletTests` covers BIP-39 validation,
   address derivation, and amount formatting.

---

## 5. Building it *without* a Mac, and getting it onto your iPhone

This is the path this project was actually set up for, since it was written on
Windows.

### Step 1 — Build the `.ipa` in the cloud

`.github/workflows/ios-build.yml` builds the app on a GitHub-hosted macOS
runner and uploads an **unsigned** `.ipa` as a workflow artifact — no Mac, no
Apple Developer account needed for this part.

1. Push this repo to GitHub (`git push`).
2. Go to the repo's **Actions** tab → the workflow runs automatically on push
   to `main`, or trigger it manually ("Run workflow").
3. When it finishes, open the run → **Summary** → download the
   `CryptoWallet-unsigned-ipa` artifact.

### Step 2 — Sign and install it with a free Apple ID (no Mac, no $99/year)

Use **[AltStore](https://altstore.io) / AltServer**, which runs on Windows and
signs + installs apps onto your iPhone over USB or Wi-Fi using nothing but a
free Apple ID:

1. Install **iTunes** (for the Apple device drivers) and then **AltServer**
   on your Windows PC from [altstore.io](https://altstore.io).
2. Plug in your iPhone (or connect both to the same Wi-Fi), open AltServer
   from the system tray → **Install AltStore** → choose your device. Sign in
   with your Apple ID when prompted — this happens entirely inside AltServer,
   never through this app.
3. On your iPhone: **Settings → General → VPN & Device Management** → trust
   the developer certificate for your Apple ID.
4. Open the **AltStore** app on your iPhone → **My Apps** → **+** → pick the
   `.ipa` you downloaded in Step 1 (AirDrop or a cloud drive folder both work
   to get the file onto the phone first).

**The catch with a free Apple ID:** apps signed this way stop launching after
**7 days** unless AltServer re-signs them, which it does automatically as long
as your iPhone and the PC running AltServer are on the same Wi-Fi periodically
(AltStore has a background refresh for this). This is an Apple platform limit,
not a limitation of this app. If you'd rather not deal with the 7-day cycle,
enroll in the [Apple Developer Program](https://developer.apple.com/programs/)
($99/year) and either install via Xcode directly or distribute through
TestFlight — no expiry either way.

---

## 6. What to verify on first build

This project could not be compiled during development (no Xcode/macOS access).
Everything was written to match documented, stable APIs, but a few specific
spots carry more risk than the rest and are the first place to look if the
build fails:

1. **`Blockchain/EVM/EVMTransactionSigner.swift`** — the WalletCore
   `EthereumSigningInput`/`EthereumSigningOutput` protobuf field names
   (`chainID`, `gasPrice`, `gasLimit`, `transaction.transfer.amount`,
   `transaction.contractGeneric`) are correct for the well-documented,
   long-stable legacy-transaction shape, but WalletCore does version these
   protobufs — if a field name has moved, this is the one file to check
   against whatever version of `wallet-core` Swift Package Manager resolves
   (`project.yml` pins `from: 4.0.0`, i.e. "4.0.0 or newer").
2. **WalletCore's prebuilt XCFramework vs. Xcode version** — WalletCore ships a
   *binary* framework compiled with a specific Swift compiler. The first CI
   run on this project failed with `this SDK is not supported by the compiler`
   because the workflow picked the newest Xcode (16.2 / Swift 6.0.3) on the
   runner, while WalletCore 4.8.3's framework was built with Swift 5.10 —
   the workflow now deliberately selects the oldest available Xcode 15.x
   instead of the newest (see the comment in `ios-build.yml`). If WalletCore
   publishes a build compiled against a newer toolchain later, that pin can
   move forward again. (For the same reason, `UI/Components/GlassCard.swift`
   intentionally does **not** use Apple's iOS 26 native Liquid Glass API —
   no available Xcode has that SDK yet; it's a hand-built `.ultraThinMaterial`
   equivalent instead, with a comment marking where to add the native path
   later.)
3. **`Wallet/Services/WalletManager.swift`** (`addAccount`) — uses
   `CoinType.derivationPath` and `PrivateKey.data`, both stable long-standing
   WalletCore APIs, to build custom-index derivation paths for the
   "additional accounts" feature. Lower risk than #1, same family of concern.
4. **Everything else** — standard SwiftUI/Foundation/Security/LocalAuthentication/
   AVFoundation/CoreImage APIs, all iOS 15–compatible and cross-checked by hand
   against the deployment target (see next section).

If the compiler flags something in files 1–3, it's a narrow, mechanical fix
(a renamed protobuf field, an argument label) — the surrounding architecture
doesn't change.

### iOS 15 compatibility, specifically

The spec required real iOS 15 support, not just an iOS 15 deployment target
number while quietly using newer-only APIs. This was audited by hand:
`NavigationStack`/`.navigationDestination` (iOS 16+) were deliberately **not**
used anywhere — the app uses `NavigationView` + classic `NavigationLink`
throughout instead (fully functional through current iOS, just deprecated in
Apple's docs). Every other iOS 16+/17+ API in the codebase
(`.contentTransition`, `.scrollContentBackground`) is behind an explicit
`if #available` with a real iOS 15 fallback, not just a lower deployment
target number that happens to compile.

---

## 7. Security model

- **Non-custodial.** No account system, no backend that ever sees your seed,
  keys, or balances.
- Seed phrases are generated with WalletCore's CSPRNG-backed BIP-39
  implementation — never `random()`, `UUID()`, or any homegrown entropy source.
- The seed is stored **only** in the iOS Keychain, under
  `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` (excluded from iCloud/iTunes
  backup) with a `SecAccessControl` requiring Face ID/Touch ID (Secure
  Enclave-backed) to read it back — every signing operation re-triggers that
  prompt, independent of the app's own lock screen.
- The seed is never logged, never sent over the network, and is wrapped in a
  best-effort self-zeroing `SecureBytes` type wherever it's held in memory
  (see `Core/Security/SecureBytes.swift`).
- Every transaction is signed **locally** and shown in full (asset, amount,
  recipient, network fee, total) before the user confirms — nothing is signed
  or broadcast without an explicit tap plus biometric confirmation.

---

## 8. Known limitations / honest gaps

- No automated UI tests — only unit tests for the parts explicitly called out
  as critical (BIP-39, derivation, formatting, network config).
- App icon is a placeholder slot (`Resources/Assets.xcassets/AppIcon.appiconset`)
  with no image — drop a 1024×1024 PNG in via Xcode's asset editor before
  App Store submission; not required for personal/sideload installs.
- Localization architecture (`SWIFT_EMIT_LOC_STRINGS`) is enabled, but only
  English strings exist today — all user-facing text is plain Swift string
  literals rather than `Localizable.strings`-backed, so wiring a second
  language means extracting those strings, not restructuring the app.
- The curated stablecoin contract addresses in `Assets/Models/TokenList.swift`
  were written from memory, not fetched live — double-check any address
  against the network's official explorer before relying on it for a real
  transfer (see the comment at the top of that file).
