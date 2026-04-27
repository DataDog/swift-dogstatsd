// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DogstatsdVaporCompatibility",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(path: "../.."),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .testTarget(
            name: "DogstatsdVaporTests",
            dependencies: [
                .product(name: "Dogstatsd", package: "swift-dogstatsd"),
                .product(name: "DogstatsdVapor", package: "swift-dogstatsd"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/DogstatsdVaporTests"
        ),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
