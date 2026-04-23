CHANGELOG
=========

# Unreleased
* Modernized the package for Swift 6 toolchains and updated the Vapor dependency.
* Split the package into `Dogstatsd` and `DogstatsdVapor` library products.
* Updated the Vapor integration to satisfy modern sendability requirements.
* Moved tests into a standard SwiftPM layout and expanded coverage.
* Added example NIO and Vapor apps, a VS Code devcontainer, and VS Code run/test tasks.
* Hardened the devcontainer bootstrap for clean SwiftPM caches and HTTPS GitHub dependency resolution.
* Added agent guidance for working in this repository.
* Corrected DogStatsD sample-rate, event, and service-check wire encoding.
* Hardened socket reconnection and made the Vapor wrapper safe before configuration.
* Added explicit NIO client shutdown support so short-lived processes and the NIO example flush metrics before exit.

# 1.0.1 / 2023-05-10
* Added unified service tagging.
* Fixed how tags are handled so they are not restricted to key/value pairs.

# 1.0.0 / 2022-04-01
* First Release 🎉
