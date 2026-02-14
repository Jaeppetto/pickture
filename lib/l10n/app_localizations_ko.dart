// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Pickture';

  @override
  String get tabHome => '홈';

  @override
  String get tabClean => '정리';

  @override
  String get tabSettings => '설정';

  @override
  String get homeTitle => '홈';

  @override
  String get cleanTitle => '정리';

  @override
  String get settingsTitle => '설정';

  @override
  String get permissionGranted => '사진 접근이 허용되었습니다';

  @override
  String get permissionLimited => '제한된 사진 접근';

  @override
  String get permissionDenied => '사진 접근이 거부되었습니다';

  @override
  String get permissionDeniedDescription => '설정에서 사진 접근을 허용해주세요';

  @override
  String get readyToOrganize => '갤러리 정리를 시작할 준비가 되었습니다';

  @override
  String get organizeYourGallery => '갤러리를 정리해보세요';

  @override
  String get allowAccessToStart => '정리를 시작하려면 사진 접근을 허용해주세요';

  @override
  String get grantPhotoAccess => '사진 접근 허용';

  @override
  String get dashboardTitle => '대시보드';

  @override
  String totalPhotosVideos(int count) {
    return '사진 및 동영상 $count장';
  }

  @override
  String get totalStorage => '총 저장 용량';

  @override
  String get photos => '사진';

  @override
  String get videos => '동영상';

  @override
  String get screenshots => '스크린샷';

  @override
  String get other => '기타';

  @override
  String get deviceStorage => '기기 저장 공간';

  @override
  String get freeSpace => '여유 공간';

  @override
  String cleaningPrediction(String size) {
    return '정리하면 $size 확보 가능';
  }

  @override
  String insightScreenshots(int count) {
    return '스크린샷 $count장';
  }

  @override
  String insightOldPhotos(int count) {
    return '6개월 이전 사진 $count장';
  }

  @override
  String insightLargeFiles(int count) {
    return '10MB 이상 파일 $count장';
  }

  @override
  String get startCleaning => '정리 시작';

  @override
  String get cleanSessionTitle => '갤러리 정리';

  @override
  String get undo => '되돌리기';

  @override
  String get resumeSession => '이어서 정리';

  @override
  String get startFresh => '처음부터';

  @override
  String get resumeSessionTitle => '이전 세션 발견';

  @override
  String get resumeSessionDescription => '이전 정리를 이어서 하시겠습니까?';

  @override
  String progressLabel(int reviewed, int total) {
    return '$reviewed/$total장 확인';
  }

  @override
  String get deleteAction => '삭제';

  @override
  String get keepAction => '보관';

  @override
  String get favoriteAction => '즐겨찾기';

  @override
  String get photoDate => '촬영일';

  @override
  String get photoSize => '크기';

  @override
  String get photoDimensions => '해상도';

  @override
  String get noPhotosToClean => '정리할 사진이 없습니다';

  @override
  String get allPhotosCleaned => '모든 사진을 확인했습니다!';

  @override
  String get deleteQueueTitle => '삭제 대기열';

  @override
  String totalToDelete(int count) {
    return '총 $count장 삭제 예정';
  }

  @override
  String totalSizeToFree(String size) {
    return '$size 확보 예정';
  }

  @override
  String get confirmDelete => '삭제 확정';

  @override
  String confirmDeleteDialog(int count) {
    return '$count장의 사진을 영구 삭제하시겠습니까?';
  }

  @override
  String get restore => '복구';

  @override
  String get sessionSummaryTitle => '정리 완료!';

  @override
  String get totalReviewed => '확인';

  @override
  String get totalDeleted => '삭제';

  @override
  String get totalKept => '보관';

  @override
  String get totalFavorited => '즐겨찾기';

  @override
  String get storageFreed => '확보 용량';

  @override
  String get viewDeleteQueue => '삭제 대기열 확인';

  @override
  String get done => '완료';

  @override
  String get deleteSuccess => '삭제가 완료되었습니다';

  @override
  String get settingsGeneral => '일반';

  @override
  String get settingsAbout => '정보';

  @override
  String get settingsVersion => '버전';

  @override
  String get settingsLicenses => '오픈소스 라이선스';

  @override
  String get trashTitle => '휴지통';

  @override
  String get trashDescription => '최근 삭제된 사진';

  @override
  String get trashEmpty => '휴지통이 비어있습니다';

  @override
  String trashItemCount(int count) {
    return '$count개 항목';
  }

  @override
  String trashStorageUsed(String size) {
    return '$size 사용 중';
  }

  @override
  String get trashRetentionNotice => '30일 후 자동으로 영구 삭제됩니다';

  @override
  String get trashRestoreSuccess => '사진이 복구되었습니다';

  @override
  String get trashDeleteSuccess => '영구 삭제되었습니다';

  @override
  String get trashEmptyAll => '휴지통 비우기';

  @override
  String trashEmptyConfirm(int count) {
    return '$count개 항목을 영구 삭제하시겠습니까?';
  }

  @override
  String trashDaysRemaining(int days) {
    return '$days일 남음';
  }

  @override
  String get trashPermanentDelete => '영구 삭제';

  @override
  String get trashMoveSuccess => '휴지통으로 이동되었습니다';

  @override
  String get statisticsTitle => '정리 통계';

  @override
  String get statTotalSessions => '세션';

  @override
  String get statTotalCleaned => '정리됨';

  @override
  String get statTotalFreed => '확보됨';

  @override
  String get statTotalReviewed => '확인됨';

  @override
  String get statNoData => '아직 정리 기록이 없습니다';

  @override
  String get statStartCleaning => '첫 번째 세션을 시작해보세요!';

  @override
  String get onboardingTitle1 => '스와이프로 정리';

  @override
  String get onboardingDesc1 => '왼쪽으로 삭제, 오른쪽으로 보관, 위로 즐겨찾기';

  @override
  String get onboardingTitle2 => '안전하고 되돌릴 수 있어요';

  @override
  String get onboardingDesc2 => '삭제된 사진은 휴지통에 보관됩니다. 30일 이내에 복구할 수 있어요';

  @override
  String get onboardingTitle3 => '진행 상황 추적';

  @override
  String get onboardingDesc3 => '정리 통계를 확인하고 저장 공간을 확보하세요';

  @override
  String get onboardingSkip => '건너뛰기';

  @override
  String get onboardingNext => '다음';

  @override
  String get onboardingGetStarted => '시작하기';

  @override
  String get reminderTitle => '정리 리마인더';

  @override
  String get reminderDescription => '매주 갤러리 정리 알림을 받아보세요';

  @override
  String get reminderNotificationTitle => '정리할 시간이에요!';

  @override
  String get reminderNotificationBody => '갤러리가 정리를 기다리고 있어요';

  @override
  String get hapticTitle => '햅틱 피드백';

  @override
  String get hapticDescription => '스와이프 시 진동 피드백';

  @override
  String comboCount(int count) {
    return '${count}x 콤보!';
  }
}
