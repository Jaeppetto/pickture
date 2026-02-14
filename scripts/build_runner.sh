#!/bin/bash
set -e

echo "Running build_runner..."
dart run build_runner build --delete-conflicting-outputs

echo "Running gen-l10n..."
flutter gen-l10n

echo "Done!"
