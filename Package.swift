// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hello-swift",
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.2.0"),
        .package(path: "./AdvanceSample"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        
        .target(name: "BasicSample"),
        
        .executableTarget(
            name: "HelloSample",
            dependencies: [
                .product(
                    name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AdvanceSample",package: "AdvanceSample"),
                "BasicSample",
            ]
        ),
        .testTarget(
            name: "HelloSampleTests",
            dependencies: [.target(name: "HelloSample")]),
    ]
)
