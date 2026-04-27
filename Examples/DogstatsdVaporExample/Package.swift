// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DogstatsdVaporExample",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(path: "../.."),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "DogstatsdVaporExample",
            dependencies: [
                .product(name: "DogstatsdVapor", package: "swift-dogstatsd"),
                .product(name: "Vapor", package: "vapor"),
            ],
            path: ".",
            exclude: ["Package.swift", "Package.resolved"]
        ),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
