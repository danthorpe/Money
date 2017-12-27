// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Money",
    products: [
        .library(name: "Money", targets: ["Money"])
    ],
    targets: [
        .target(name: "Money", path: "Sources"),
        .testTarget(name: "MoneyTests", path: "Tests")
    ]
)
