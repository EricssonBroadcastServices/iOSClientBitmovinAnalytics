// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSClientBitmovinAnalytics",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "iOSClientBitmovinAnalytics",
            targets: ["iOSClientBitmovinAnalytics"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/bitmovin/player-ios.git",
            .upToNextMajor(from: "3.0.0")
        )
    ],
    targets: [
        .target(
            name: "iOSClientBitmovinAnalytics",
            dependencies: [
                .product(name: "BitmovinPlayer", package: "player-ios")
            ]
        ),
        .testTarget(
            name: "iOSClientBitmovinAnalyticsTests",
            dependencies: ["iOSClientBitmovinAnalytics"]
        ),
    ]
)
