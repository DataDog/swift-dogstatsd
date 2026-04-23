# Agent Guide

## Repo Map

- `Package.swift`: SwiftPM manifest. The package now targets Swift 6-era toolchains and pins the current Vapor dependency line.
- `Sources/Dogstatsd/`: library implementation.
- `Sources/DogstatsdVapor/`: Vapor-specific integration layered on the core package.
- `Examples/`: runnable example apps for pure NIO and Vapor usage.
- `Tests/DogstatsdCoreTests/`: core package coverage.
- `Tests/DogstatsdVaporTests/`: Vapor integration coverage.
- `README.md`: public usage and verification notes.
- `.devcontainer/`: contributor container setup for VS Code / Dev Containers.

## Working Norms

- Run `swift test` before wrapping up changes.
- Always run the unit tests and make sure they pass before pushing or committing changes.
- Prefer small, targeted edits over broad refactors unless the task explicitly asks for structural changes.
- Keep dependency changes intentional and pinned. If a pin changes, verify the full test suite again.
- Do not introduce public breaking API changes without checking with the author first.

## Branch And Commit Policy

- On `main` or `master`: never commit without asking first.
- On topic branches: commit as needed.
