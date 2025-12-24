// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdvanceSample",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AdvanceSample",
            targets: ["AdvanceSample"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.2"),
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.92.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AdvanceSample", dependencies: [
                "SwiftyJSON"
            ]),
        .testTarget(
            name: "AdvanceSampleTests",
            dependencies: ["AdvanceSample"]
        ),
    ]
)
