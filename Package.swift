// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GlassGem",
    products: [
        .library(
            name: "GlassGem",
            targets: ["GlassGem"]),
    ],
    targets: [
        .target(
            name: "GlassGem",
            dependencies: []),
        .testTarget(
            name: "GlassGemTests",
            dependencies: ["GlassGem"]),
    ]
)
