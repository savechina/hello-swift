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
        .package(url: "https://github.com/thebarndog/swift-dotenv.git", from: "2.0.0"),
        // Phase 3: Vapor Web Framework
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "4.0.0")),
        // Phase 3: GRDB SQLite Database
        .package(url: "https://github.com/groue/GRDB.swift.git", .upToNextMajor(from: "6.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AdvanceSample", dependencies: [
                "SwiftyJSON",
                .product(name: "SwiftDotenv", package: "swift-dotenv"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                // Phase 3: Vapor
                .product(name: "Vapor", package: "vapor"),
                // Phase 3: GRDB
                .product(name: "GRDB", package: "GRDB.swift")
            ]),
        .testTarget(
            name: "AdvanceSampleTests",
            dependencies: ["AdvanceSample"]
        ),
    ]
)
