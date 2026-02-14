abstract final class AppConstants {
  // App info
  static const appName = 'Pickture';

  // Animation durations (milliseconds)
  static const durationFast = Duration(milliseconds: 150);
  static const durationNormal = Duration(milliseconds: 300);
  static const durationSlow = Duration(milliseconds: 500);
  static const durationSwipe = Duration(milliseconds: 400);

  // Spacing (8dp grid)
  static const spacing2 = 2.0;
  static const spacing4 = 4.0;
  static const spacing8 = 8.0;
  static const spacing12 = 12.0;
  static const spacing16 = 16.0;
  static const spacing24 = 24.0;
  static const spacing32 = 32.0;
  static const spacing48 = 48.0;
  static const spacing64 = 64.0;

  // Border radius
  static const radiusSmall = 8.0;
  static const radiusMedium = 12.0;
  static const radiusLarge = 16.0;
  static const radiusXLarge = 24.0;
  static const radiusRound = 999.0;

  // Elevation
  static const elevationNone = 0.0;
  static const elevationLow = 2.0;
  static const elevationMedium = 4.0;
  static const elevationHigh = 8.0;

  // Photo loading
  static const photoPageSize = 50;
  static const thumbnailSize = 200;

  // Swipe thresholds
  static const swipeThreshold = 100.0;
  static const swipeUpThreshold = 80.0;
  static const swipeVelocityThreshold = 800.0;

  // Card stack
  static const cardStackSize = 3;
  static const cardStackOffset = 8.0;
  static const cardStackScale = 0.02;

  // Storage thresholds
  static const largeSizeThreshold = 10 * 1024 * 1024; // 10 MB
  static const oldPhotoMonths = 6;

  // Cleaning session
  static const preloadCount = 3;
  static const nextBatchThreshold = 10;
  static const persistInterval = 10;
}
