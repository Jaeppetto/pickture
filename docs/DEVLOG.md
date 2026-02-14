# Pickture Development Log

## 2026-02-15 — Phase 1: Foundation

### Completed
- Migrated from Flutter to iOS native (Swift/SwiftUI)
- Set up XcodeGen-based project generation (`project.yml`)
- Created full Clean Architecture directory structure
- Implemented design system: colors, typography, spacing, theme
- Created domain entities: Photo, CleaningSession, CleaningDecision, TrashItem, etc.
- Defined repository protocols for all data boundaries
- Implemented stub data layer (repositories + data sources)
- Built presentation layer: MainTabView with 3 tabs (Home, Clean, Settings)
- Set up localization infrastructure (String Catalog, ko/en/ja/zh-Hans)
- Created unit tests for domain entities
- Configured SwiftLint strict mode
- Wrote ADR-001 (iOS Native + XcodeGen) and ADR-002 (Clean Architecture + MVVM)

### Architecture Decisions
- XcodeGen for project generation (ADR-001)
- Clean Architecture + MVVM (ADR-002)
- @Observable macro for state management
- Actor-based DataSources for concurrency safety
- Protocol-based DI with AppContainer as composition root
- String Catalog (.xcstrings) for localization
- Portrait-only orientation
