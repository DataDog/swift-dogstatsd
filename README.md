# Swift Dogstatsd
![Platforms](https://img.shields.io/badge/platforms-macOS%2010.15%2B-ff0000.svg?style=flat)
[![Swift 6](https://img.shields.io/badge/swift-6.0%2B-orange.svg?style=flat)](https://swift.org)
[![Vapor 4.121.4](https://img.shields.io/badge/vapor-4.121.4-blue.svg?style=flat)](https://vapor.codes)

## Overview

Swift Dogstatsd is a DogStatsD client for Vapor applications.

The current package manifest targets modern Swift 6 toolchains and pins the Vapor dependency graph to the latest verified Vapor 4 release line.


## Installation
Add Swift Dogstatsd with Swift Package Manager:

```swift
.package(url: "https://github.com/DataDog/swift-dogstatsd.git", from: "1.0.0"),

.target(name: "App", dependencies: [
    .product(name: "Vapor", package: "vapor"),
    .product(name: "Dogstatsd", package: "dogstatsd")
])
```

Development in this repository is currently validated with Swift `6.2.4` and a manifest baseline of `swift-tools-version: 6.0`.

## Usage

### Configuration

In `configure.swift`:

```swift
import Dogstatsd

// Called before your application initializes.
func configure(_ app: Application) throws {

    app.dogstatsd.config = .udp(address: "127.0.0.1", port: 8125)
    // or 
    app.dogstatsd.config = .uds(path: "/tmp/dsd.sock")

}
```

### Sending Metrics

`dogstatsd` is available on both `Application` and `Request`:

```swift
import Vapor

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
