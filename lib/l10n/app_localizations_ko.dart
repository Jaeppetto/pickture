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
}
