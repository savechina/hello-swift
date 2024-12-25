// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hello-swift",
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.5.0"),
        .package(
            url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
        .package(path: "./AdvanceSample"),
        .package(path: "./AwesomeSample"),
        .package(path: "./LeetCodeSample"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.

        .target(name: "BasicSample"),
        .target(
            name: "AlgoSample",
            dependencies: [
                .product(
                    name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Numerics", package: "swift-numerics"),
            ]),
        .executableTarget(
            name: "HelloSample",
            dependencies: [
                .product(
                    name: "ArgumentParser", package: "swift-argument-parser"),
                .product(
                    name: "Algorithms", package: "swift-algorithms"),
                .product(name: "AdvanceSample", package: "AdvanceSample"),
                .product(name: "AwesomeSample", package: "AwesomeSample"),
                .product(name: "LeetCodeSample", package: "LeetCodeSample"),
                "BasicSample", "AlgoSample",
            ]
        ),
        .testTarget(
            name: "HelloSampleTests",
            dependencies: [.target(name: "HelloSample")]
        ),

        .testTarget(
            name: "AlgoSampleTests",
            dependencies: [.target(name: "AlgoSample")]
        ),
    ]
)
