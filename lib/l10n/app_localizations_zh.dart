// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Pickture';

  @override
  String get tabHome => '首页';

  @override
  String get tabClean => '整理';

  @override
  String get tabSettings => '设置';

  @override
  String get homeTitle => '首页';

  @override
  String get cleanTitle => '整理';

  @override
  String get settingsTitle => '设置';

  @override
  String get permissionGranted => '已获得照片访问权限';

  @override
  String get permissionLimited => '照片访问受限';

  @override
  String get permissionDenied => '照片访问被拒绝';

  @override
  String get permissionDeniedDescription => '请在设置中开启照片访问权限';

  @override
  String get readyToOrganize => '已准备好整理您的相册';

  @override
  String get organizeYourGallery => '整理您的相册';

  @override
  String get allowAccessToStart => '请授权以开始整理';

  @override
  String get grantPhotoAccess => '授权访问照片';

  @override
  String get dashboardTitle => '仪表盘';

  @override
  String totalPhotosVideos(int count) {
    return '照片和视频 $count项';
  }

  @override
  String get totalStorage => '总存储空间';

  @override
  String get photos => '照片';

  @override
  String get videos => '视频';

  @override
  String get screenshots => '截图';

  @override
  String get other => '其他';

  @override
  String get deviceStorage => '设备存储';

  @override
  String get freeSpace => '可用空间';

  @override
  String cleaningPrediction(String size) {
    return '清理可释放$size';
  }

  @override
  String insightScreenshots(int count) {
    return '$count张截图';
  }

  @override
  String insightOldPhotos(int count) {
    return '$count张6个月前的照片';
  }

  @override
  String insightLargeFiles(int count) {
    return '$count个超过10MB的文件';
  }

  @override
  String get startCleaning => '开始整理';

  @override
  String get cleanSessionTitle => '相册整理';

  @override
  String get undo => '撤销';

  @override
  String get resumeSession => '继续整理';

  @override
  String get startFresh => '重新开始';

  @override
  String get resumeSessionTitle => '发现之前的会话';

  @override
  String get resumeSessionDescription => '是否继续之前的整理？';

  @override
  String progressLabel(int reviewed, int total) {
    return '已检查$reviewed/$total';
  }

  @override
  String get deleteAction => '删除';

  @override
  String get keepAction => '保留';

  @override
  String get favoriteAction => '收藏';

  @override
  String get photoDate => '拍摄日期';

  @override
  String get photoSize => '大小';

  @override
  String get photoDimensions => '分辨率';

  @override
  String get noPhotosToClean => '没有需要整理的照片';

  @override
  String get allPhotosCleaned => '所有照片已检查完毕！';

  @override
  String get deleteQueueTitle => '删除队列';

  @override
  String totalToDelete(int count) {
    return '共$count项待删除';
  }

  @override
  String totalSizeToFree(String size) {
    return '将释放$size';
  }

  @override
  String get confirmDelete => '确认删除';

  @override
  String confirmDeleteDialog(int count) {
    return '确定永久删除$count张照片吗？';
  }

  @override
  String get restore => '恢复';

  @override
  String get sessionSummaryTitle => '整理完成！';

  @override
  String get totalReviewed => '已检查';

  @override
  String get totalDeleted => '已删除';

  @override
  String get totalKept => '已保留';

  @override
  String get totalFavorited => '已收藏';

  @override
  String get storageFreed => '已释放空间';

  @override
  String get viewDeleteQueue => '查看删除队列';

  @override
  String get done => '完成';

  @override
  String get deleteSuccess => '删除完成';

  @override
  String get settingsGeneral => '通用';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsLicenses => '开源许可证';

  @override
  String get trashTitle => '回收站';

  @override
  String get trashDescription => '最近删除的照片';

  @override
  String get trashEmpty => '回收站为空';

  @override
  String trashItemCount(int count) {
    return '$count项';
  }

  @override
  String trashStorageUsed(String size) {
    return '已使用$size';
  }

  @override
  String get trashRetentionNotice => '30天后将自动永久删除';

  @override
  String get trashRestoreSuccess => '照片已恢复';

  @override
  String get trashDeleteSuccess => '已永久删除';

  @override
  String get trashEmptyAll => '清空回收站';

  @override
  String trashEmptyConfirm(int count) {
    return '确定永久删除$count个项目吗？';
  }

  @override
  String trashDaysRemaining(int days) {
    return '剩余$days天';
  }

  @override
  String get trashPermanentDelete => '永久删除';

  @override
  String get trashMoveSuccess => '已移至回收站';

  @override
  String get statisticsTitle => '清理统计';

  @override
  String get statTotalSessions => '会话';

  @override
  String get statTotalCleaned => '已清理';

  @override
  String get statTotalFreed => '已释放';

  @override
  String get statTotalReviewed => '已查看';

  @override
  String get statNoData => '还没有清理记录';

  @override
  String get statStartCleaning => '开始你的第一次清理吧！';

  @override
  String get onboardingTitle1 => '滑动整理';

  @override
  String get onboardingDesc1 => '向左滑动删除，向右保留，向上收藏';

  @override
  String get onboardingTitle2 => '安全可恢复';

  @override
  String get onboardingDesc2 => '删除的照片先进入回收站，30天内可以恢复';

  @override
  String get onboardingTitle3 => '追踪进度';

  @override
  String get onboardingDesc3 => '查看清理统计，释放存储空间';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingGetStarted => '开始使用';

  @override
  String get reminderTitle => '清理提醒';

  @override
  String get reminderDescription => '每周接收相册清理提醒';

  @override
  String get reminderNotificationTitle => '该整理了！';

  @override
  String get reminderNotificationBody => '你的相册正在等待清理';

  @override
  String get hapticTitle => '触觉反馈';

  @override
  String get hapticDescription => '滑动时的振动反馈';

  @override
  String comboCount(int count) {
    return '${count}x连击！';
  }
}
