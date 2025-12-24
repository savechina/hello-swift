// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hello-swift",
    //    platforms: [
    //        .macOS(.v13),  // 支持 macOS 13 及更高版本
    //        .iOS(.v13),  // 支持 iOS 13 及更高版本
    //    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.5.0"),
        .package(
            url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(
            url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git",
            from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.3.0")),
        .package(path: "./AdvanceSample"),
        .package(path: "./AwesomeSample"),
        .package(path: "./LeetCodeSample"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.

        .target(
            name: "BasicSample",
            dependencies: [
                .product(name: "Logging", package: "swift-log"), "SwiftyBeaver",
                .product(name: "Collections", package: "swift-collections")
            ]),
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
