// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DogstatsdNIOExample",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(path: "../.."),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.82.0"),
    ],
    targets: [
        .executableTarget(
            name: "DogstatsdNIOExample",
            dependencies: [
                .product(name: "DogstatsdCore", package: "swift-dogstatsd"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ],
            path: ".",
            exclude: ["Package.swift", "Package.resolved"]
        ),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
