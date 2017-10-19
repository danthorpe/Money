// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Money",
    products: [
        .library(name: "Money", targets: ["Money"])
    ],
    dependencies: [
        .package(url: "https://github.com/danthorpe/ValueCoding.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "Money", dependencies: ["ValueCoding"], path: "Sources"),
        .testTarget(name: "MoneyTests", dependencies: ["Money"], path: "Tests")
    ]
)
