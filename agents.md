# Agent Guide

## Repo Map

- `Package.swift`: SwiftPM manifest. The package now targets Swift 6-era toolchains and pins the current Vapor dependency line.
- `Sources/Dogstatsd/`: library implementation.
- `Tests/DogstatsdTests/`: unit and integration coverage for metric encoding, sender behavior, and Vapor integration.
- `README.md`: public usage and verification notes.

## Working Norms

- Run `swift test` before wrapping up changes.
- Prefer small, targeted edits over broad refactors unless the task explicitly asks for structural changes.
- Keep dependency changes intentional and pinned. If a pin changes, verify the full test suite again.

## Branch And Commit Policy

- On `main` or `master`: never commit without asking first.
- On topic branches: commit as needed.
