# App Store Screenshots Guide

## Required Screenshots

App Store requires screenshots for each supported device size.

### Device Sizes

| Device | Resolution | Required |
|--------|-----------|----------|
| iPhone 6.9" (16 Pro Max) | 1320 x 2868 | Yes |
| iPhone 6.7" (15 Pro Max) | 1290 x 2796 | Yes |
| iPhone 6.5" (11 Pro Max) | 1242 x 2688 | Optional (if 6.7" provided) |
| iPhone 5.5" (8 Plus) | 1242 x 2208 | Optional |

### Required Screens (minimum 3, recommended 5)

1. **Home Dashboard** - Storage overview, stats badges, last session summary
2. **Swipe Cleaning** - Card stack with photo, keep/delete action buttons
3. **Deletion Queue** - Grid of pending deletions with selection
4. **Cleaning Complete** - Confetti celebration with session stats
5. **Settings** - Language options, haptic feedback toggle, privacy link

### Screenshot Capture Steps

1. Launch simulator: `iPhone 16 Pro Max (iOS 18.x)`
2. Populate with sample photos (use Photos app or drag-and-drop)
3. Navigate to each screen
4. Capture: `Cmd + S` in Simulator or `xcrun simctl io booted screenshot <filename>.png`
5. Place screenshots in this directory with naming: `{number}_{screen}_{device}.png`

### Naming Convention

```
01_home_6.7.png
02_cleaning_6.7.png
03_deletion_queue_6.7.png
04_complete_6.7.png
05_settings_6.7.png
```

### Guidelines (Apple 2.3.3, 2.3.4)

- Screenshots must reflect actual app functionality
- No misleading images or promises
- UI must match the submitted app version
- All text in screenshots should be legible
- Consider adding localized screenshots for each supported language
