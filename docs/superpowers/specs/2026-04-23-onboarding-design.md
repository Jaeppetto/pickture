# Pickture First-Run Onboarding Design

## Goal

Improve Pickture's first impression without changing the core cleaning workflow. The first-run experience should communicate storage relief and brand energy before asking for photo access.

Approved direction:

- Primary value: make the phone feel lighter by cleaning accumulated photos.
- Brand tone: rhythmic and memorable, led by `Swipe. Clean. Lighten.`
- Flow style: one-time root onboarding after the splash screen.

## User Flow

1. App launches and shows the existing `SplashScreenView`.
2. If onboarding has not been completed, `RootView` shows `OnboardingScreen`.
3. The user taps `Start Pickture`.
4. A short trust sheet appears before any system permission prompt.
5. The user taps `Continue`.
6. The app stores onboarding completion and enters `MainTabView`.
7. Existing `PhotoPermissionView` handles photo authorization states.

For returning users with completed onboarding, the app skips directly from splash to `MainTabView`.

## Screen Composition

`OnboardingScreen` uses the existing brutalist brand language:

- Small `Pickture.` brand mark near the top.
- Central stacked card illustration that suggests delete/keep swiping.
- Large headline:
  - `Swipe.`
  - `Clean.`
  - `Lighten.`
- Supporting copy:
  - Korean source: `사진을 넘기듯 정리하고, 내 폰은 더 가볍게.`
- One primary CTA: `Start Pickture`.

The previously considered helper text, `사진 권한은 다음 단계에서 요청됩니다.`, is explicitly out of scope and must not appear on the screen.

## Trust Sheet

The CTA opens a compact bottom sheet. It must stay short and avoid a tutorial-like flow.

Trust signals:

- Photos are processed on device.
- Deletions are reviewed once more in the deletion queue.

Primary action:

- `Continue`

After `Continue`, onboarding is marked complete and the user proceeds into the existing app flow.

## Animation Direction

Use high-quality motion actively, but keep it purposeful. Motion should make the first-run experience feel polished and should guide attention toward the next action.

Required animation moments:

- Onboarding entrance: the central card stack should pop in with a spring response after the splash fades.
- Card illustration: delete/keep cards should make a subtle staggered settle or float motion, not a looping distracting animation.
- Headline reveal: `Swipe. Clean. Lighten.` should appear in a short stepped sequence that matches the three-word rhythm.
- CTA feedback: `Start Pickture` should use pressed-state scale/haptic feedback consistent with the app's existing brutalist controls.
- Trust sheet transition: use a native-feeling sheet presentation with smooth dimming and a clear upward motion.
- Completion transition: after `Continue`, the app should crossfade or slide cleanly into `MainTabView` without a blank or intermediate flash. The existing photo permission gate may appear as part of `MainTabView` content when authorization is still needed.

Accessibility requirements:

- Respect Reduce Motion. When reduce motion is enabled, use simple opacity transitions and avoid floating/settling movement.
- Do not block user interaction while decorative animations finish.
- Keep touch targets at least 44pt.

## State Storage

Do not add onboarding completion to `UserPreference`.

Reason: existing preferences are stored as encoded JSON. Adding a new non-optional property to `UserPreference` can make existing saved preferences fail decoding and reset locale or haptic settings.

Use a dedicated `UserDefaults` key instead:

- Key: `onboarding_completed`
- Type: `Bool`
- Default: `false`
- Set to `true` only when the user taps `Continue` in the trust sheet.

Introduce `OnboardingStateStore` as the dedicated state boundary so `RootView` does not directly own raw `UserDefaults` access.

## i18n

All new user-facing strings must be added to `Pickture/Resources/Localizable/Localizable.xcstrings`.

Supported localizations:

- `ko`
- `en`
- `ja`
- `zh-Hans`

New strings include:

- `Swipe. Clean. Lighten.`
- `사진을 넘기듯 정리하고, 내 폰은 더 가볍게.`
- `Start Pickture`
- `사진은 기기 안에서만 처리됩니다.`
- `삭제 전 대기열에서 한 번 더 확인합니다.`
- `Continue`

The source language remains Korean, matching the existing string catalog. `Swipe. Clean. Lighten.`, `Start Pickture`, and `Continue` may remain English in Korean if that is the desired brand treatment, but they still need explicit entries for all supported locales.

## Implementation Boundaries

Add or update these units:

- `OnboardingScreen`: first-run brand screen and CTA.
- `OnboardingTrustSheet`: compact trust sheet shown after CTA.
- `OnboardingStateStore`: dedicated persistence wrapper for `onboarding_completed`.
- `RootView`: route between onboarding and `MainTabView` after splash.
- `Localizable.xcstrings`: add all new strings in the four supported languages.
- `.gitignore`: ignore `.superpowers/` local brainstorming files.

Do not change:

- The core swipe cleaning flow.
- Photo loading, deletion queue, or cleaning session domain behavior.
- Existing `PhotoPermissionView` permission result handling.

## Edge Cases

- If the user denies photo access after onboarding, the existing denied permission screen is shown.
- If onboarding completion is not saved for any reason, the onboarding may appear again on the next launch. This is acceptable and does not need an error UI.
- Changing app language after onboarding should continue to update visible app strings through the existing locale environment. Completed onboarding is not shown again only to reflect language changes.

## Test Plan

Manual verification:

- Fresh install or cleared defaults shows splash, then onboarding.
- `Start Pickture` opens the trust sheet.
- `Continue` stores onboarding completion and enters `MainTabView`.
- Relaunch skips onboarding once completion is stored.
- New strings render in `ko`, `en`, `ja`, and `zh-Hans`.
- Reduce Motion avoids nonessential movement.
- `.superpowers/` does not appear in `git status`.

Required automated coverage:

- Unit test `OnboardingStateStore` default, save, and reload behavior using an isolated `UserDefaults` suite.

Optional automated coverage:

- UI test or view-level smoke path for first-run onboarding completion, only if it can be added without expanding the current test harness.

## Repository Hygiene

`.superpowers/` contains local visual brainstorming screens, server state, and interaction logs. It should remain ignored and should not be committed.

Only this approved spec should be committed as the durable record of the brainstorming decisions.
