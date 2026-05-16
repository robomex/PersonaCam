// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PersonaCam",
    platforms: [
        .visionOS(.v2)
    ],
    products: [
        .library(name: "PersonaCam",
                 targets: ["PersonaCam"]),
    ],
    targets: [
        .target(name: "PersonaCam"),
        .testTarget(name: "PersonaCamTests",
                    dependencies: ["PersonaCam"]),
    ]
)
