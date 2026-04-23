# First-Run Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Do not commit; the user explicitly requested no commits.

**Goal:** Build a one-time animated first-run onboarding flow for Pickture before the existing photo permission flow.

**Architecture:** Add a small `OnboardingStateStore` persistence boundary for the `onboarding_completed` flag. Route in `RootView` after the existing splash. Keep permission handling in the existing `PhotoPermissionView`.

**Tech Stack:** Swift 6, SwiftUI, Swift Testing, UserDefaults, String Catalog (`Localizable.xcstrings`).

---

### Task 1: Onboarding State Store

**Files:**
- Create: `Pickture/App/OnboardingStateStore.swift`
- Create: `PicktureTests/App/OnboardingStateStoreTests.swift`
- Modify: `Pickture/App/AppContainer.swift`

- [ ] **Step 1: Write failing tests**

```swift
import Foundation
import Testing

@testable import Pickture

@Suite("OnboardingStateStore Tests")
struct OnboardingStateStoreTests {
    @Test("defaults to incomplete when key is missing")
    func defaultsToIncomplete() {
        let defaults = UserDefaults(suiteName: "OnboardingStateStoreTests.defaults")!
        defaults.removePersistentDomain(forName: "OnboardingStateStoreTests.defaults")
        let store = OnboardingStateStore(defaults: defaults)

        #expect(store.hasCompletedOnboarding == false)
    }

    @Test("persists completed state")
    func persistsCompletedState() {
        let defaults = UserDefaults(suiteName: "OnboardingStateStoreTests.persists")!
        defaults.removePersistentDomain(forName: "OnboardingStateStoreTests.persists")
        let store = OnboardingStateStore(defaults: defaults)

        store.markCompleted()
        let reloaded = OnboardingStateStore(defaults: defaults)

        #expect(reloaded.hasCompletedOnboarding == true)
    }
}
```

- [ ] **Step 2: Run test and verify RED**

Run: `xcodebuild test -scheme Pickture -destination 'platform=iOS Simulator,name=iPhone 16' -derivedDataPath /tmp/pickture-derived-data -only-testing:PicktureTests/OnboardingStateStoreTests`

Expected: FAIL because `OnboardingStateStore` does not exist.

- [ ] **Step 3: Implement store and DI**

```swift
import Foundation

final class OnboardingStateStore {
    private let defaults: UserDefaults
    private let completionKey = "onboarding_completed"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        defaults.bool(forKey: completionKey)
    }

    func markCompleted() {
        defaults.set(true, forKey: completionKey)
    }
}
```

Add `let onboardingStateStore = OnboardingStateStore()` to `AppContainer`.

- [ ] **Step 4: Run test and verify GREEN**

Run the same `xcodebuild test` command.

Expected: PASS.

### Task 2: Onboarding UI

**Files:**
- Create: `Pickture/Presentation/Screens/Onboarding/OnboardingScreen.swift`

- [ ] **Step 1: Implement focused SwiftUI screen**

Create `OnboardingScreen` with:

- `onCompleted: () -> Void`
- `@Environment(\.accessibilityReduceMotion)`
- animated card stack illustration
- stepped headline reveal for `Swipe. Clean. Lighten.`
- primary `Start Pickture` CTA
- `.sheet` trust sheet with two localized trust rows and `Continue`
- no helper text about photo permission being requested next

- [ ] **Step 2: Apply motion rules**

Use spring/staggered animations when Reduce Motion is disabled. Use opacity-only transitions when Reduce Motion is enabled. CTA remains tappable immediately.

### Task 3: Root Routing

**Files:**
- Modify: `Pickture/App/PicktureApp.swift`

- [ ] **Step 1: Route after splash**

In `RootView`, add state initialized from `container.onboardingStateStore.hasCompletedOnboarding`.

After splash:

- show `OnboardingScreen` when onboarding is incomplete
- call `container.onboardingStateStore.markCompleted()` from onboarding completion
- transition into the existing `MainTabView`

### Task 4: Localization

**Files:**
- Modify: `Pickture/Resources/Localizable/Localizable.xcstrings`

- [ ] **Step 1: Add keys**

Add `ko`, `en`, `ja`, and `zh-Hans` values for:

- `Swipe. Clean. Lighten.`
- `사진을 넘기듯 정리하고, 내 폰은 더 가볍게.`
- `Start Pickture`
- `사진은 기기 안에서만 처리됩니다.`
- `삭제 전 대기열에서 한 번 더 확인합니다.`
- `Continue`

### Task 5: Repository Hygiene and Verification

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Ignore local brainstorming files**

Ensure `.superpowers/` is ignored.

- [ ] **Step 2: Run verification**

Run:

```bash
xcodebuild test -scheme Pickture -destination 'platform=iOS Simulator,name=iPhone 16' -derivedDataPath /tmp/pickture-derived-data
git status --short
```

Expected:

- Tests pass.
- `.superpowers/` does not appear.
- Existing unrelated `Pickture/Presentation/Components/SwipeCardView.swift` remains unstaged and untouched by this implementation.
