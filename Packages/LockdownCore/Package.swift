// swift-tools-version:5.10
import PackageDescription

// Pure Swift, Foundation only. No UIKit, no CoreMotion, no AVFoundation, so the
// whole package builds and tests on macOS, Linux and CI without an iOS simulator.
let package = Package(
    name: "LockdownCore",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(name: "LockdownCore", targets: ["LockdownCore"]),
    ],
    targets: [
        .target(name: "LockdownCore"),
        .testTarget(name: "LockdownCoreTests", dependencies: ["LockdownCore"]),
    ]
)
