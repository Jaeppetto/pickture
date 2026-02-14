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
}
