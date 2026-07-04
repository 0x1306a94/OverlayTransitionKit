// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OverlayTransitionKit",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "OverlayTransitionKit",
            targets: ["OverlayTransitionKit"]
        ),
    ],
    targets: [
        .target(
            name: "OverlayTransitionKit"
        ),
        .testTarget(
            name: "OverlayTransitionKitTests",
            dependencies: ["OverlayTransitionKit"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
