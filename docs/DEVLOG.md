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

## 2026-02-16 — Feature Changes: Simplify Cleaning & Settings

### Changes
- **Removed favorite feature entirely:** Deleted `.favorite` from `Decision` enum, removed `totalFavorited` from `CleaningSession`, removed upward swipe gesture/overlay/color/haptic from `SwipeCardView`, removed star button from action bar, removed favorite stat from progress view and session summary, removed `AppColors.favorite` and `favoriteGradient`.
- **Redesigned cleaning start page as a 5-item list:** Replaced the 3-button layout (filter sheet / no-filter start / start position picker) with a clean list: All Photos, Screenshots, Videos, Start Position Picker, Random. Deleted `FilterSelectionSheet.swift`.
- **Added random shuffle mode:** New `isShuffled` flag in `CleanViewModel`. When enabled, each page of loaded photos is shuffled before display. Triggered via "랜덤" option on start page.
- **Removed theme picker from settings:** Removed the "테마" section from `SettingsScreen` and `updateThemeMode()` from `SettingsViewModel`. App follows system appearance.
- **Added language selection to settings:** Added "언어" section with Picker (ko/en/ja/zh-Hans). Wired `SettingsViewModel.updateLocale()` to persist choice. `PicktureApp` now applies `.environment(\.locale, ...)` from the shared settings view model for immediate locale reflection.
- **Made `settingsViewModel` shared in `AppContainer`:** Changed from factory to lazy shared instance so `PicktureApp` can observe locale changes.

### Files Modified
- `Domain/Entities/CleaningDecision.swift` — removed `.favorite` case
- `Domain/Entities/CleaningSession.swift` — removed `totalFavorited`
- `Domain/UseCases/ProcessSwipeDecisionUseCase.swift` — removed `.favorite` case
- `Presentation/Components/SwipeCardView.swift` — removed upward swipe/overlay/color
- `Presentation/Screens/Clean/CleaningActiveView.swift` — removed star button
- `Presentation/ViewModels/CleanViewModel.swift` — removed favorite, added shuffle, removed filterSelection state
- `Presentation/Components/CleaningProgressView.swift` — removed favorite stat
- `Presentation/Screens/Clean/SessionSummaryView.swift` — removed favorite stat card
- `Presentation/Components/ConfettiView.swift` — removed favorite color
- `Core/Extensions/HapticManager.swift` — removed `swipeFavorite()`
- `Core/Theme/AppColors.swift` — removed `favorite`, `favoriteGradient`
- `Presentation/Screens/Clean/CleanScreen.swift` — new 5-item list, removed filter sheet
- `Presentation/Components/FilterSelectionSheet.swift` — **deleted**
- `Presentation/Screens/Settings/SettingsScreen.swift` — removed theme section, added language section
- `Presentation/ViewModels/SettingsViewModel.swift` — removed `updateThemeMode()`, added `updateLocale()`
- `App/AppContainer.swift` — shared `settingsViewModel`
- `App/PicktureApp.swift` — locale environment from settings, RootView extraction
- `Presentation/Screens/MainTabView.swift` — use shared settingsViewModel

## 2026-02-16 — 15-Item UI/Feature Improvement

### Changes
- **Home screen overhaul (Items 1,2,3,4):** Removed "오늘의 정리" quickActionCard and insightsSection. Reordered dashboard to storageCard → statsRow → startCleaningButton → trashQueueButton. Renamed CTA to "스와이프 정리 시작". Added trash queue button showing count when > 0. DeletionQueueScreen sheet with onDismiss trash count refresh.
- **Settings tab removed, language moved to home (Item 14):** Removed settings tab entirely (2-tab layout: Home, Clean). Added globe icon Menu in HomeScreen toolbar for language selection (ko/en/ja/zh-Hans).
- **Clean idle view refinement (Item 5):** Removed surfaceStyle container from header. Changed Label to centered Text with title.bold() font.
- **TopStatusBar removed (Item 6):** Removed topStatusBar, remainingCount, captureTimeText, timeFormatter from CleaningActiveView.
- **Card tap metadata sheet removed (Item 7):** Removed onTapped parameter from SwipeCardView and SwipeCardStackView. Removed selectedMetadataPhoto, showMetadata(), hideMetadata() from CleanViewModel. Removed PhotoMetadataOverlay overlay from CleaningActiveView.
- **Action button colors (Item 8):** Changed delete color to Color.red, keep to Color.green. Updated deleteGradient/keepGradient to red/green based.
- **Swipe overlay redesign (Item 9):** Replaced gradient badge + icon with inner glow (colored stroke + blur) and text-only label with shadow glow.
- **Card stack animation (Item 10):** Added .animation(.spring(...), value: currentIndex) to background cards for smooth scale/offset/opacity interpolation.
- **Trash count refresh on dismiss (Item 11):** Handled via DeletionQueueScreen sheet onDismiss calling loadTrashCount().
- **Filter-based session resume (Item 12):** Added persistenceKey to CleaningFilter. Added filter index save/load/clear to LocalStorageDataSource, CleaningSessionRepositoryProtocol, CleaningSessionRepository. CleanViewModel now checks for saved index on startNewSession, shows resume alert, supports resumeFromSavedIndex() and startFresh(). Index saved on each swipe, cleared on session complete.
- **Shimmer loading (Item 13):** Added ShimmerModifier and .shimmer() extension in View+Extensions. Applied skeleton + shimmer to HomeScreen storage loading and CleaningActiveView photo loading.
- **Language instant refresh + toast (Item 15):** Added refreshId + .id() to RootView for instant locale refresh. Added toast overlay with language-specific messages and 2-second auto-dismiss.

### Files Modified
- `Presentation/ViewModels/HomeViewModel.swift` — removed insights, added trashRepository/trashItemCount/loadTrashCount
- `Presentation/Screens/Home/HomeScreen.swift` — removed quickActionCard/insightsSection, added language menu/trash queue/skeleton
- `Presentation/Screens/MainTabView.swift` — removed settings tab, 2-tab layout
- `App/AppContainer.swift` — pass trashRepository to HomeViewModel
- `Presentation/Screens/Clean/CleanScreen.swift` — centered header text, resume alert
- `Presentation/Screens/Clean/CleaningActiveView.swift` — removed topStatusBar/metadata overlay, added card skeleton
- `Presentation/Components/SwipeCardView.swift` — removed onTapped, inner glow overlay
- `Presentation/Components/SwipeCardStackView.swift` — removed onTapped, added background card animation
- `Presentation/ViewModels/CleanViewModel.swift` — removed metadata, added resume alert/filter index persistence
- `Core/Theme/AppColors.swift` — red delete, green keep colors
- `Core/Extensions/View+Extensions.swift` — added ShimmerModifier
- `App/PicktureApp.swift` — refreshId for instant locale, toast overlay
- `Domain/Entities/CleaningFilter.swift` — added persistenceKey
- `Data/DataSources/LocalStorageDataSource.swift` — filter session index CRUD
- `Domain/Repositories/CleaningSessionRepositoryProtocol.swift` — filter index methods
- `Data/Repositories/CleaningSessionRepository.swift` — filter index implementation

### Bug Fixes
- **Language not changing:** Removed `.id(refreshId)` from RootView — it destroyed the entire view tree on locale change, resetting all `@State`. Now relies on `@Observable` tracking for locale propagation via `.environment(\.locale)`.
- **Toast not disappearing:** Replaced `DispatchQueue.main.asyncAfter` with cancellable `DispatchWorkItem` timer. Previous implementation broke due to view recreation.
- **Card transition animation:** Added `appeared` state to SwipeCardView with spring animation (scale 0.965→1.0, offset 12→0) for a natural "coming forward" effect on card entrance.
- **Trash queue button not showing:** Added eager `loadTrashCount()` call in HomeScreen `.task` before permission check. Previously only ran after `loadStorageInfo()` which gated on permissions.
- **Deletion queue count not refreshing:** Fixed by ensuring `loadTrashCount()` runs reliably (related to trash button fix above). `onDismiss` handler was correct but count was stale from ViewModel reset.
- **Session index not persisted on completion:** Removed `clearFilterIndex()` from `completeSession()`. Index now persists until user explicitly chooses "처음부터" in the resume alert.
