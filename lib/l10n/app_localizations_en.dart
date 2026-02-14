// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pickture';

  @override
  String get tabHome => 'Home';

  @override
  String get tabClean => 'Clean';

  @override
  String get tabSettings => 'Settings';

  @override
  String get homeTitle => 'Home';

  @override
  String get cleanTitle => 'Clean';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get permissionGranted => 'Photo access granted';

  @override
  String get permissionLimited => 'Limited photo access';

  @override
  String get permissionDenied => 'Photo access denied';

  @override
  String get permissionDeniedDescription =>
      'Please enable photo access in Settings';

  @override
  String get readyToOrganize => 'Ready to organize your gallery';

  @override
  String get organizeYourGallery => 'Organize your gallery';

  @override
  String get allowAccessToStart => 'Allow access to start cleaning';

  @override
  String get grantPhotoAccess => 'Grant Photo Access';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String totalPhotosVideos(int count) {
    return '$count items';
  }

  @override
  String get totalStorage => 'Total Storage';

  @override
  String get photos => 'Photos';

  @override
  String get videos => 'Videos';

  @override
  String get screenshots => 'Screenshots';

  @override
  String get other => 'Other';

  @override
  String get deviceStorage => 'Device Storage';

  @override
  String get freeSpace => 'Free Space';

  @override
  String cleaningPrediction(String size) {
    return 'Clean up to free $size';
  }

  @override
  String insightScreenshots(int count) {
    return '$count Screenshots';
  }

  @override
  String insightOldPhotos(int count) {
    return '$count photos older than 6 months';
  }

  @override
  String insightLargeFiles(int count) {
    return '$count files over 10MB';
  }

  @override
  String get startCleaning => 'Start Cleaning';

  @override
  String get cleanSessionTitle => 'Gallery Cleaning';

  @override
  String get undo => 'Undo';

  @override
  String get resumeSession => 'Resume Session';

  @override
  String get startFresh => 'Start Fresh';

  @override
  String get resumeSessionTitle => 'Previous Session Found';

  @override
  String get resumeSessionDescription =>
      'Would you like to continue your previous session?';

  @override
  String progressLabel(int reviewed, int total) {
    return '$reviewed/$total reviewed';
  }

  @override
  String get deleteAction => 'Delete';

  @override
  String get keepAction => 'Keep';

  @override
  String get favoriteAction => 'Favorite';

  @override
  String get photoDate => 'Date';

  @override
  String get photoSize => 'Size';

  @override
  String get photoDimensions => 'Dimensions';

  @override
  String get noPhotosToClean => 'No photos to clean';

  @override
  String get allPhotosCleaned => 'All photos reviewed!';

  @override
  String get deleteQueueTitle => 'Delete Queue';

  @override
  String totalToDelete(int count) {
    return '$count items to delete';
  }

  @override
  String totalSizeToFree(String size) {
    return '$size to free';
  }

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteDialog(int count) {
    return 'Permanently delete $count photos?';
  }

  @override
  String get restore => 'Restore';

  @override
  String get sessionSummaryTitle => 'Cleaning Complete!';

  @override
  String get totalReviewed => 'Reviewed';

  @override
  String get totalDeleted => 'Deleted';

  @override
  String get totalKept => 'Kept';

  @override
  String get totalFavorited => 'Favorited';

  @override
  String get storageFreed => 'Storage Freed';

  @override
  String get viewDeleteQueue => 'View Delete Queue';

  @override
  String get done => 'Done';

  @override
  String get deleteSuccess => 'Deletion complete';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsLicenses => 'Licenses';

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashDescription => 'Recently deleted photos';

  @override
  String get trashEmpty => 'Trash is empty';

  @override
  String trashItemCount(int count) {
    return '$count items';
  }

  @override
  String trashStorageUsed(String size) {
    return '$size used';
  }

  @override
  String get trashRetentionNotice =>
      'Items are permanently deleted after 30 days';

  @override
  String get trashRestoreSuccess => 'Photo restored';

  @override
  String get trashDeleteSuccess => 'Permanently deleted';

  @override
  String get trashEmptyAll => 'Empty Trash';

  @override
  String trashEmptyConfirm(int count) {
    return 'Permanently delete all $count items?';
  }

  @override
  String trashDaysRemaining(int days) {
    return '${days}d left';
  }

  @override
  String get trashPermanentDelete => 'Delete Forever';

  @override
  String get trashMoveSuccess => 'Moved to trash';

  @override
  String get statisticsTitle => 'Cleaning Stats';

  @override
  String get statTotalSessions => 'Sessions';

  @override
  String get statTotalCleaned => 'Cleaned';

  @override
  String get statTotalFreed => 'Freed';

  @override
  String get statTotalReviewed => 'Reviewed';

  @override
  String get statNoData => 'No cleaning data yet';

  @override
  String get statStartCleaning => 'Start your first session!';

  @override
  String get onboardingTitle1 => 'Swipe to Clean';

  @override
  String get onboardingDesc1 =>
      'Swipe left to delete, right to keep, up to favorite';

  @override
  String get onboardingTitle2 => 'Safe & Reversible';

  @override
  String get onboardingDesc2 =>
      'Deleted photos go to trash first. You can restore them within 30 days';

  @override
  String get onboardingTitle3 => 'Track Progress';

  @override
  String get onboardingDesc3 =>
      'See your cleaning stats and free up storage space';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get reminderTitle => 'Cleaning Reminder';

  @override
  String get reminderDescription =>
      'Get weekly reminders to clean your gallery';

  @override
  String get reminderNotificationTitle => 'Time to clean!';

  @override
  String get reminderNotificationBody =>
      'Your gallery is waiting for a cleanup session';

  @override
  String get hapticTitle => 'Haptic Feedback';

  @override
  String get hapticDescription => 'Vibration feedback on swipe actions';

  @override
  String comboCount(int count) {
    return '${count}x Combo!';
  }
}
