# Agent Guide

## Repo Map

- `Package.swift`: root SwiftPM manifest for the published library products and the core unit tests.
- `Sources/Dogstatsd/`: library implementation.
- `Sources/DogstatsdVapor/`: Vapor-specific integration layered on the core package.
- `Examples/`: runnable example apps, each with its own local SwiftPM package.
- `Tests/DogstatsdCoreTests/`: core package coverage.
- `Compatibility/VaporCompatibility/`: separate local package for Vapor integration and backward-compatibility tests.
- `README.md`: public usage and verification notes.
- `.devcontainer/`: contributor container setup for VS Code / Dev Containers.

## Working Norms

- Run `swift test` before wrapping up changes.
- Always run the unit tests and make sure they pass before pushing or committing changes.
- Prefer small, targeted edits over broad refactors unless the task explicitly asks for structural changes.
- Keep dependency changes intentional and use normal version ranges in package manifests unless the author explicitly approves something narrower.
- Do not introduce public breaking API changes without checking with the author first.

## Branch And Commit Policy

- On `main` or `master`: never commit without asking first.
- On topic branches: commit as needed.
