// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Pickture';

  @override
  String get tabHome => 'ホーム';

  @override
  String get tabClean => '整理';

  @override
  String get tabSettings => '設定';

  @override
  String get homeTitle => 'ホーム';

  @override
  String get cleanTitle => '整理';

  @override
  String get settingsTitle => '設定';

  @override
  String get permissionGranted => '写真へのアクセスが許可されました';

  @override
  String get permissionLimited => '写真への限定アクセス';

  @override
  String get permissionDenied => '写真へのアクセスが拒否されました';

  @override
  String get permissionDeniedDescription => '設定から写真へのアクセスを許可してください';

  @override
  String get readyToOrganize => 'ギャラリーの整理を始める準備ができました';

  @override
  String get organizeYourGallery => 'ギャラリーを整理しましょう';

  @override
  String get allowAccessToStart => '整理を始めるにはアクセスを許可してください';

  @override
  String get grantPhotoAccess => '写真アクセスを許可';

  @override
  String get dashboardTitle => 'ダッシュボード';

  @override
  String totalPhotosVideos(int count) {
    return '写真と動画 $count件';
  }

  @override
  String get totalStorage => '合計容量';

  @override
  String get photos => '写真';

  @override
  String get videos => '動画';

  @override
  String get screenshots => 'スクリーンショット';

  @override
  String get other => 'その他';

  @override
  String get deviceStorage => 'デバイスストレージ';

  @override
  String get freeSpace => '空き容量';

  @override
  String cleaningPrediction(String size) {
    return '整理すると$sizeを確保できます';
  }

  @override
  String insightScreenshots(int count) {
    return 'スクリーンショット$count件';
  }

  @override
  String insightOldPhotos(int count) {
    return '6ヶ月以上前の写真$count件';
  }

  @override
  String insightLargeFiles(int count) {
    return '10MB以上のファイル$count件';
  }

  @override
  String get startCleaning => '整理を始める';

  @override
  String get cleanSessionTitle => 'ギャラリー整理';

  @override
  String get undo => '元に戻す';

  @override
  String get resumeSession => '続きから整理';

  @override
  String get startFresh => '最初から';

  @override
  String get resumeSessionTitle => '前回のセッションを検出';

  @override
  String get resumeSessionDescription => '前回の整理を続けますか？';

  @override
  String progressLabel(int reviewed, int total) {
    return '$reviewed/$total件確認済み';
  }

  @override
  String get deleteAction => '削除';

  @override
  String get keepAction => '保管';

  @override
  String get favoriteAction => 'お気に入り';

  @override
  String get photoDate => '撮影日';

  @override
  String get photoSize => 'サイズ';

  @override
  String get photoDimensions => '解像度';

  @override
  String get noPhotosToClean => '整理する写真がありません';

  @override
  String get allPhotosCleaned => 'すべての写真を確認しました！';

  @override
  String get deleteQueueTitle => '削除キュー';

  @override
  String totalToDelete(int count) {
    return '合計$count件を削除予定';
  }

  @override
  String totalSizeToFree(String size) {
    return '$sizeを解放予定';
  }

  @override
  String get confirmDelete => '削除を確定';

  @override
  String confirmDeleteDialog(int count) {
    return '$count件の写真を完全に削除しますか？';
  }

  @override
  String get restore => '復元';

  @override
  String get sessionSummaryTitle => '整理完了！';

  @override
  String get totalReviewed => '確認';

  @override
  String get totalDeleted => '削除';

  @override
  String get totalKept => '保管';

  @override
  String get totalFavorited => 'お気に入り';

  @override
  String get storageFreed => '確保した容量';

  @override
  String get viewDeleteQueue => '削除キューを確認';

  @override
  String get done => '完了';

  @override
  String get deleteSuccess => '削除が完了しました';
}
