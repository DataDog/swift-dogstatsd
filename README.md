# Swift Dogstatsd
![Platforms](https://img.shields.io/badge/platforms-macOS%2010.15%2B-ff0000.svg?style=flat)
[![Swift 6](https://img.shields.io/badge/swift-6.0%2B-orange.svg?style=flat)](https://swift.org)
[![Vapor 4.121.4](https://img.shields.io/badge/vapor-4.121.4-blue.svg?style=flat)](https://vapor.codes)

## Overview

Swift Dogstatsd is a DogStatsD client with two library products:

- `Dogstatsd`: the core NIO-backed client and metric API.
- `DogstatsdVapor`: Vapor-specific integration on top of the core client.

The current package manifest targets modern Swift 6 toolchains and is validated locally with Swift `6.2.4`.


## Installation
Add Swift Dogstatsd with Swift Package Manager:

```swift
.package(url: "https://github.com/DataDog/swift-dogstatsd.git", from: "1.0.0"),
```

### Core NIO Client

Use only the core product if you want the DogStatsD client and metric APIs:

```swift
.target(name: "App", dependencies: [
    .product(name: "Dogstatsd", package: "swift-dogstatsd")
])
```

### Vapor Integration

Use the Vapor product if you want `Application` and `Request` extensions:

```swift
.target(name: "App", dependencies: [
    .product(name: "DogstatsdVapor", package: "swift-dogstatsd")
])
```

Note: the package is split into separate products, but SwiftPM still resolves package-level dependencies for the repository. In practice that means consumers can choose the `Dogstatsd` or `DogstatsdVapor` module they use, but some tools may still fetch the Vapor dependency graph even when only the core product is selected.

## Usage

### Core NIO Client

The core package works on its own without Vapor:

```swift
import Dogstatsd
import NIO

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let client = try NIODogstatsdClient(
    on: eventLoopGroup,
    clientConfig: .udp(address: "127.0.0.1", port: 8125)
)

client.increment("custom.swift.metric", tags: ["env:prod"])
```

### Vapor Integration

`DogstatsdVapor` adds the Vapor-specific extensions:

```swift
import DogstatsdVapor

// Called before your application initializes.
func configure(_ app: Application) throws {

    app.dogstatsd.config = .udp(address: "127.0.0.1", port: 8125)
    // or 
    app.dogstatsd.config = .uds(path: "/tmp/dsd.sock")

}
```

After configuration, `dogstatsd` is available on both `Application` and `Request`:

```swift
import Vapor
import DogstatsdVapor

func routes(_ app: Application) throws {
    app.get { req -> String in
        req.dogstatsd.increment("custom.swift.metric", tags: ["env:prod"])
        return "It works!"
    }
}
```

## Testing

Run the test suite with:

```bash
swift test
```
