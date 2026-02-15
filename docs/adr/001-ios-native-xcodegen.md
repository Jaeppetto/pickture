# ADR-001: iOS Native with XcodeGen

## Status

Accepted

## Date

2026-02-15

## Context

Pickture was originally planned as a Flutter cross-platform app. After evaluation, we decided to migrate to iOS native (Swift/SwiftUI) for the following reasons:

- **Performance**: Native PhotoKit integration avoids bridge overhead for photo library operations at scale (30,000+ photos).
- **UX Quality**: SwiftUI provides native gesture system, spring animations, and haptic feedback without third-party dependencies.
- **Platform Features**: Direct access to PHCachingImageManager, PHFetchResultChangeDetails, and other iOS-specific APIs.
- **App Size**: Native app is significantly smaller than Flutter equivalent.

### XcodeGen Decision

CLI-based development (Claude Code) cannot manipulate `.xcodeproj` binary plists directly. Options considered:

| Option                     | Pros                                            | Cons                                    |
| -------------------------- | ----------------------------------------------- | --------------------------------------- |
| **XcodeGen**               | Declarative YAML, deterministic output, easy CI | Extra tooling dependency                |
| Manual xcodeproj           | No dependencies                                 | Impossible from CLI                     |
| Swift Package (executable) | SPM native                                      | Not suitable for iOS app targets        |
| Tuist                      | Full project generation                         | Heavier tooling, steeper learning curve |

## Decision

Use **XcodeGen** to generate `.xcodeproj` from a declarative `project.yml` specification.

## Consequences

- `project.yml` is the source of truth for project configuration.
- `.xcodeproj` is generated and can be gitignored (though we keep it for Xcode users).
- Adding new files requires running `xcodegen generate` to update the project.
- CI must install xcodegen (`brew install xcodegen`).
- `scripts/generate_project.sh` provided for convenience.
