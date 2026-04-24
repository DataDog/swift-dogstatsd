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
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
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
                .product(name: "Vapor", package: "vapor"),
            ],
            path: "Sources/DogstatsdVapor"
        ),
        .testTarget(
            name: "DogstatsdCoreTests",
            dependencies: [
                .target(name: "DogstatsdCore"),
            ],
            path: "Tests/DogstatsdCoreTests"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
