#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

if ! command -v swiftlint &> /dev/null; then
    echo "Error: swiftlint is not installed. Run: brew install swiftlint"
    exit 1
fi

echo "Running SwiftLint..."
swiftlint lint --strict

echo "Lint passed."
