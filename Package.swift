// swift-tools-version:6.0
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
            name: "DogstatsdVapor",
            targets: ["DogstatsdVapor"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", exact: "2.99.0"),
        .package(url: "https://github.com/vapor/vapor.git", exact: "4.121.4"),
    ],
    targets: [
        .target(
            name: "Dogstatsd",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
            ]
        ),
        .target(
            name: "DogstatsdVapor",
            dependencies: [
                .target(name: "Dogstatsd"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(
            name: "DogstatsdCoreTests",
            dependencies: [
                .target(name: "Dogstatsd"),
            ],
            path: "Tests/DogstatsdCoreTests"
        ),
        .testTarget(
            name: "DogstatsdVaporTests",
            dependencies: [
                .target(name: "Dogstatsd"),
                .target(name: "DogstatsdVapor"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/DogstatsdVaporTests"
        )
    ],
    swiftLanguageModes: [
        .v6
    ]
)
