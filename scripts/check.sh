#!/bin/bash
set -e

echo "=== Format Check ==="
dart format --set-exit-if-changed .

echo "=== Analyze ==="
dart analyze

echo "=== Build Runner ==="
dart run build_runner build --delete-conflicting-outputs

echo "=== Gen L10n ==="
flutter gen-l10n

echo "=== Tests ==="
flutter test

echo "=== All checks passed! ==="
