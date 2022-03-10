// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "dogstatsd",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
            // Products define the executables and libraries produced by a package, and make them visible to other packages.
            .library(
                name: "Dogstatsd",
                targets: ["Dogstatsd"]),
        ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.52.1"),
    ],
    targets: [
        .target(
            name: "Dogstatsd",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .testTarget(name: "DogstatsdTests", dependencies: [
            .target(name: "Dogstatsd"),
        ])
    ]
)
