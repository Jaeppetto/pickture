#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

if ! command -v xcodegen &> /dev/null; then
    echo "Error: xcodegen is not installed. Run: brew install xcodegen"
    exit 1
fi

echo "Generating Xcode project..."
xcodegen generate

echo "Project generated successfully."
