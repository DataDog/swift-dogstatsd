#!/usr/bin/env bash

set -euo pipefail

# Some developer environments rewrite GitHub HTTPS URLs to SSH. SwiftPM resolves
# dependencies through git inside the container, so normalize GitHub back to
# HTTPS to avoid depending on container SSH credentials.
git config --global --unset-all url.git@github.com:.insteadof || true
git config --global url."https://github.com/".insteadOf git@github.com:

# Keep container builds separate from the host machine's default `.build`
# directory. Sharing a SwiftPM module cache between macOS and Linux can produce
# path-sensitive PCH/SwiftShims failures when contributors switch contexts.
rm -rf .build-devcontainer

swift build --scratch-path .build-devcontainer
swift test --scratch-path .build-devcontainer
