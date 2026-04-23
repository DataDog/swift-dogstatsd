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
import NIOPosix

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let client = try NIODogstatsdClient(
    on: eventLoopGroup,
    clientConfig: .udp(address: "127.0.0.1", port: 8125)
)
defer { try? client.shutdown() }

client.increment("custom.swift.metric", tags: ["env:prod"])
```

For short-lived processes like CLIs or scripts, call `client.shutdown()` before tearing down the event loop group so queued metrics are flushed and the UDP channel closes cleanly.

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

## Example Apps

Two executable example apps are included for local verification and contributor onboarding:

- `DogstatsdNIOExample`: a minimal pure-NIO client that sends a couple of example metrics.
- `DogstatsdVaporExample`: a Vapor app that wires up `app.dogstatsd` and emits a metric on each request.

Run them with:

```bash
swift run DogstatsdNIOExample
swift run DogstatsdVaporExample
```

Both examples default to `DOGSTATSD_HOST=127.0.0.1` and `DOGSTATSD_PORT=8125`.

## Devcontainer

This repository includes a VS Code devcontainer in [.devcontainer/devcontainer.json](/Users/brian.floersch/dev/swift-dogstatsd/.devcontainer/devcontainer.json).

After opening the repo in the container, the post-create step runs:

```bash
rm -rf .build-devcontainer && swift build --scratch-path .build-devcontainer && swift test --scratch-path .build-devcontainer
```

The container uses its own SwiftPM scratch path so Linux container builds do not corrupt the host macOS `.build` database.
It also normalizes GitHub remotes to HTTPS during setup so SwiftPM does not depend on SSH keys inside the container.

VS Code workspace helpers are also included in [launch.json](/Users/brian.floersch/dev/swift-dogstatsd/.vscode/launch.json) and [tasks.json](/Users/brian.floersch/dev/swift-dogstatsd/.vscode/tasks.json) for:

- building the package
- running the unit tests
- running the NIO example app
- running the Vapor example app

Use the VS Code test task for unit tests rather than a launch configuration. The example apps are exposed in `launch.json` because they are meant to stay running, while tests are finite commands and should exit through the task runner.

That gives contributors a ready-to-use Swift environment plus the included example apps and test suite.
