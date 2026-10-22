// swift-tools-version: 6.1
import PackageDescription

// This review branch defaults to Skip Fuse and pins the attributed-text changes.
// SKIP_MODE=lite selects the transpiled comparison build.
// Set SKIP_MODE=fuse to depend on SkipFuseUI + SkipSQLPlus and compile with SKIP_MODE_FUSE defined,
// which also causes skipstone to build the Showcase module in `native` mode
// (Sources/Showcase/Skip/skip.yml sets `mode: 'automatic'`, which becomes 'native' when SkipFuse is present).
//
// Example usage: SKIP_MODE=fuse skip app launch
let defaultMode = "fuse"
let fuse = (Context.environment["SKIP_MODE"] ?? defaultMode) == "fuse"

let package = Package(
    name: "skipapp-showcase",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14), .tvOS(.v17), .watchOS(.v10), .macCatalyst(.v17)],
    products: [
        .library(name: "Showcase", type: .dynamic, targets: ["Showcase"]),
    ],
    dependencies: [
        fuse ? .package(url: "https://github.com/tifroz/skip-fuse-ui.git", revision: "8c78981dde21d7d90cb9e75ce8af7f8d03ac4682")
             : .package(url: "https://github.com/tifroz/skip-ui.git", revision: "f3f7c277108d54059adcdbe640499a598e9db978"),
        .package(url: "https://github.com/skiptools/skip.git", from: "1.9.7"),
        .package(url: "https://github.com/skiptools/skip-kit.git", from: "1.1.3"),
        .package(url: "https://github.com/skiptools/skip-av.git", "0.7.2"..<"2.0.0"),
        .package(url: "https://github.com/skiptools/skip-web.git", "0.11.3"..<"2.0.0"),
        .package(url: "https://github.com/skiptools/skip-sql.git", "0.16.0"..<"2.0.0"),
        .package(url: "https://github.com/skiptools/skip-device.git", "0.5.3"..<"2.0.0"),
        .package(url: "https://github.com/skiptools/skip-motion.git", "0.7.2"..<"2.0.0"),
        .package(url: "https://github.com/skiptools/skip-notify.git", "0.2.0"..<"2.0.0"),
        .package(url: "https://github.com/skiptools/skip-keychain.git", "0.3.3"..<"2.0.0"),
        .package(url: "https://github.com/skiptools/skip-marketplace.git", "0.4.1"..<"2.0.0"),
        .package(url: "https://github.com/skiptools/skip-authentication-services.git", "0.1.0"..<"2.0.0"),
        .package(url: "https://github.com/skiptools/skip-contacts.git", "0.2.1"..<"2.0.0"),
        .package(url: "https://github.com/skiptools/skip-calendar.git", "0.2.0"..<"2.0.0"),
    ],
    targets: [
        .target(name: "Showcase", dependencies: [
            fuse ? .product(name: "SkipFuseUI", package: "skip-fuse-ui")
                 : .product(name: "SkipUI", package: "skip-ui"),
            fuse ? .product(name: "SkipSQLPlus", package: "skip-sql")
                 : .product(name: "SkipSQL", package: "skip-sql"),
            // Android has no system SQLite, so the Fuse build uses SkipSQLPlus there and SkipSQL only on Apple
            // platforms. Linking both into the Android app puts SkipSQLCore and SkipFFI into two dynamic
            // libraries, which swift-build rejects as a diamond.
            .product(name: "SkipSQL", package: "skip-sql", condition: fuse ? .when(platforms: [.iOS, .macOS, .tvOS, .watchOS, .macCatalyst]) : nil),
            .product(name: "SkipAV", package: "skip-av"),
            .product(name: "SkipKit", package: "skip-kit"),
            .product(name: "SkipWeb", package: "skip-web"),
            .product(name: "SkipDevice", package: "skip-device"),
            .product(name: "SkipMotion", package: "skip-motion"),
            .product(name: "SkipNotify", package: "skip-notify"),
            .product(name: "SkipKeychain", package: "skip-keychain"),
            .product(name: "SkipMarketplace", package: "skip-marketplace"),
            .product(name: "SkipAuthenticationServices", package: "skip-authentication-services"),
            .product(name: "SkipContacts", package: "skip-contacts"),
            .product(name: "SkipCalendar", package: "skip-calendar"),
        ], resources: [.process("Resources")],
                swiftSettings: [.define(fuse ? "SKIP_MODE_FUSE" : "SKIP_MODE_LITE", .when(platforms: [.android]))],
           plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)

// Pin the transitive SkipUI dependency at the app root, so the SkipFuseUI PR
// can retain its upstream dependency declaration. Leave SKIP_DEPENDENCY_ROOT
// unset when resolving or building this review snapshot.
if fuse {
    package.dependencies.append(.package(url: "https://github.com/tifroz/skip-ui.git", revision: "f3f7c277108d54059adcdbe640499a598e9db978"))
}
