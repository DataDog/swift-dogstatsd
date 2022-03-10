# Swift Dogstatsd
[![Platforms](https://img.shields.io/badge/platforms-macOS%2010.15%20|%20Ubuntu%2016.04%20LTS-ff0000.svg?style=flat)](http://cocoapods.org/pods/FASwift)
[![Swift 5.3](https://img.shields.io/badge/swift-5.3-orange.svg?style=flat)](http://swift.org)
[![Vapor 4](https://img.shields.io/badge/vapor-4.0-blue.svg?style=flat)](https://vapor.codes)

##

Swift Dogstatsd is a dogstatsd implementation for the popular Vapor framework. 


## Installation
Swift Dogstatsd can be installed with Swift Package Manager

```swift
// TODO: Update for release
.package(name: "dogstatsd", url: "https://github.com/DataDog/hackathon-swift-dogstatsd.git", .branch("master")),

.target(name: "App", dependencies: [
    .product(name: "Vapor", package: "vapor"),
    .product(name: "Dogstatsd", package: "dogstatsd")
])
```

## Usage

### Configure

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

### Usage

`dogstatsd` is available on both `Application` and `Request`

```swift
import Vapor

func routes(_ app: Application) throws {

    app.get { req -> String in

        req.dogstatsd.increment("custom.swift.metric", tags: ["env": "prod"])

        return "It works!"
    }
}

```