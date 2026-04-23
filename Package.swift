// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "dogstatsd",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "Dogstatsd",
            targets: ["Dogstatsd"]
        ),
        .library(
            name: "DogstatsdCore",
            targets: ["DogstatsdCore"]
        ),
        .library(
            name: "DogstatsdVapor",
            targets: ["DogstatsdVapor"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", exact: "2.82.0"),
        // Vapor 4.117.x otherwise resolves AsyncKit 1.17.0, which fails on Swift 6.1/6.2
        // due to MemberImportVisibility issues in transitive collection types.
        .package(url: "https://github.com/vapor/async-kit.git", exact: "1.20.0"),
        .package(url: "https://github.com/vapor/vapor.git", exact: "4.117.2"),
    ],
    targets: [
        .target(
            name: "DogstatsdCore",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
            ],
            path: "Sources/Dogstatsd"
        ),
        .target(
            name: "Dogstatsd",
            dependencies: [
                .target(name: "DogstatsdCore"),
                .target(name: "DogstatsdVapor"),
            ],
            path: "Sources/DogstatsdCompatibility"
        ),
        .target(
            name: "DogstatsdVapor",
            dependencies: [
                .target(name: "DogstatsdCore"),
                .product(name: "AsyncKit", package: "async-kit"),
                .product(name: "Vapor", package: "vapor"),
            ],
            path: "Sources/DogstatsdVapor"
        ),
        .executableTarget(
            name: "DogstatsdNIOExample",
            dependencies: [
                .target(name: "DogstatsdCore"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ],
            path: "Examples/DogstatsdNIOExample"
        ),
        .executableTarget(
            name: "DogstatsdVaporExample",
            dependencies: [
                .target(name: "DogstatsdVapor"),
                .product(name: "Vapor", package: "vapor"),
            ],
            path: "Examples/DogstatsdVaporExample"
        ),
        .testTarget(
            name: "DogstatsdCoreTests",
            dependencies: [
                .target(name: "DogstatsdCore"),
            ],
            path: "Tests/DogstatsdCoreTests"
        ),
        .testTarget(
            name: "DogstatsdVaporTests",
            dependencies: [
                .target(name: "DogstatsdCore"),
                .target(name: "Dogstatsd"),
                .target(name: "DogstatsdVapor"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/DogstatsdVaporTests"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
