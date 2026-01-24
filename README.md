# Pickture 📸
**Clean your gallery effortlessly.**

Pickture is a premium Gallery Cleaning application built with **React Native (Expo)**. It helps you quickly review and delete unwanted photos using a Tinder-like swipe interface, interacting directly with your device's real media library.

---

## 🚀 How to Run

1.  **Install Dependencies**:
    ```bash
    npm install
    ```
2.  **Start the Expo Server**:
    ```bash
    npx expo start --clear
    ```
    *(The `--clear` flag is recommended to ensure assets and translation keys are loaded correctly)*

3.  **Run on Device**:
    - **Physical Device (Recommended)**: Scan the QR code with the **Expo Go** app. This allows access to your real photo gallery.
    - **Simulator**: `Press i` for iOS or `Press a` for Android. *(Note: Simulators have limited stock photos)*.

---

## 📝 Version History (Patch Notes)

### v0.6.0 - Identity & Assets 🎨
*   **App Identity**: Generated and applied custom **App Icon** and **Splash Screen** matching the "Dark Aurora" theme.
*   **Cleanup**: Removed all legacy `mockData` and unused assets.
*   **Final Polish**: Verified all TypeScript types and strict mode compliance.

### v0.5.1 - UX Refinement ✨
*   **Color Bends**: Enhanced the background opacity (0.9) and tuned blur intensity for a vibrant, glowing effect.
*   **Strict Favorites**: "Favorites Mode" now strictly filters for the system "Favorites" smart album.
*   **Reactive Language**: Fixed an issue where changing language didn't immediately update the Home screen text.
*   **UI Consistency**: Aligned Home screen card styles and moved "Favorites" to the bottom list for better reachability.

### v0.5.0 - Visual Overhaul (React Bits) �
*   **New Background**: Replaced `AuroraBackground` with **`ColorBends`** – a custom implementation using rotating linear gradient layers and heavy blur to simulate the popular `react-bits` web effect natively.
*   **Stability**: Fixed a persistent `lodash` bundling error within `expo-router`.

### v0.4.0 - Localization & Safety 🌏
*   **Global Localization**: Added support for **English**, **Korean (한국어)**, and **Japanese (日本語)**.
    *   Implemented `LanguageContext` for persistent language selection.
    *   Added instant Language Toggle to the Home Screen header.
*   **Exit Confirmation**: Added a safety alert when trying to leave the Swipe screen with un-emptied trash to prevent accidental data loss.

### v0.3.0 - Premium Experience 💎
*   **Toast System**: Implemented a global `ToastContext` to show non-intrusive feedback (e.g., "Deleted 5 Items") after actions.
*   **Image Prefetching**: Added intelligent prefetching to the Swipe stack (`expo-image`) to eliminate white flashes and loading spinners during rapid swiping.
*   **Aurora Foundation**: Initial implementation of the animated mesh gradient concept.

### v0.2.0 - Real Gallery Integration 📱
*   **Media Library**: Integrated `expo-media-library` to fetch real photos from the user's device.
*   **New Home Screen**: Created a dashboard to select cleaning modes:
    *   **Last Month**: Clean recent memories.
    *   **This Year**: Review 2024/2025 photos.
    *   **Random**: Quick session with 50 random photos.
*   **Permanent Deletion**: The "Empty Trash" action now triggers the official OS dialog to permanently delete photos from the device.

### v0.1.0 - Prototype 🛠️
*   **Initial Setup**: Project initialized with Expo Router.
*   **Design System**: Defined Dark Theme colors (`Colors.ts`) and typography.
*   **Core Mechanics**: Implemented `SwipeCard` with `react-native-reanimated` and `react-native-gesture-handler`.
*   **Screens**: Built the foundational `Swipe` interface and grid-based `Review` screen.

---

## 📂 Key Features

*   **Real-Time Deletion**: Interacts directly with iOS/Android Photos app.
*   **Swipe Gestures**: Smooth, native 60fps animations.
*   **Safety Net**: Review bin allows Undoing before permanent deletion.
*   **Filter Modes**: Temporal filters (Month/Year) and Album filters (Favorites).
*   **Privacy First**: Photos never leave the device; all processing is local.
