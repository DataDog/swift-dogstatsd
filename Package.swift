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
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", exact: "4.121.4"),
    ],
    targets: [
        .target(
            name: "Dogstatsd",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(
            name: "DogstatsdTests",
            dependencies: [
                .target(name: "Dogstatsd"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/DogstatsdTests"
        )
    ],
    swiftLanguageModes: [
        .v6
    ]
)
