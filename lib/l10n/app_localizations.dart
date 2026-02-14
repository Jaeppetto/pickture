import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// App name
  ///
  /// In ko, this message translates to:
  /// **'Pickture'**
  String get appName;

  /// Home tab label
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get tabHome;

  /// Clean tab label
  ///
  /// In ko, this message translates to:
  /// **'정리'**
  String get tabClean;

  /// Settings tab label
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get tabSettings;

  /// Home screen title
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get homeTitle;

  /// Clean screen title
  ///
  /// In ko, this message translates to:
  /// **'정리'**
  String get cleanTitle;

  /// Settings screen title
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// Permission granted message
  ///
  /// In ko, this message translates to:
  /// **'사진 접근이 허용되었습니다'**
  String get permissionGranted;

  /// Permission limited message
  ///
  /// In ko, this message translates to:
  /// **'제한된 사진 접근'**
  String get permissionLimited;

  /// Permission denied message
  ///
  /// In ko, this message translates to:
  /// **'사진 접근이 거부되었습니다'**
  String get permissionDenied;

  /// Permission denied description
  ///
  /// In ko, this message translates to:
  /// **'설정에서 사진 접근을 허용해주세요'**
  String get permissionDeniedDescription;

  /// Ready to organize message
  ///
  /// In ko, this message translates to:
  /// **'갤러리 정리를 시작할 준비가 되었습니다'**
  String get readyToOrganize;

  /// Organize your gallery message
  ///
  /// In ko, this message translates to:
  /// **'갤러리를 정리해보세요'**
  String get organizeYourGallery;

  /// Allow access to start message
  ///
  /// In ko, this message translates to:
  /// **'정리를 시작하려면 사진 접근을 허용해주세요'**
  String get allowAccessToStart;

  /// Grant photo access button
  ///
  /// In ko, this message translates to:
  /// **'사진 접근 허용'**
  String get grantPhotoAccess;

  /// Dashboard screen title
  ///
  /// In ko, this message translates to:
  /// **'대시보드'**
  String get dashboardTitle;

  /// Total photos and videos count label
  ///
  /// In ko, this message translates to:
  /// **'사진 및 동영상 {count}장'**
  String totalPhotosVideos(int count);

  /// Total storage label
  ///
  /// In ko, this message translates to:
  /// **'총 저장 용량'**
  String get totalStorage;

  /// Photos category label
  ///
  /// In ko, this message translates to:
  /// **'사진'**
  String get photos;

  /// Videos category label
  ///
  /// In ko, this message translates to:
  /// **'동영상'**
  String get videos;

  /// Screenshots category label
  ///
  /// In ko, this message translates to:
  /// **'스크린샷'**
  String get screenshots;

  /// Other category label
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get other;

  /// Device storage label
  ///
  /// In ko, this message translates to:
  /// **'기기 저장 공간'**
  String get deviceStorage;

  /// Free space label
  ///
  /// In ko, this message translates to:
  /// **'여유 공간'**
  String get freeSpace;

  /// Predicted storage freed by cleaning
  ///
  /// In ko, this message translates to:
  /// **'정리하면 {size} 확보 가능'**
  String cleaningPrediction(String size);

  /// Insight card showing screenshot count
  ///
  /// In ko, this message translates to:
  /// **'스크린샷 {count}장'**
  String insightScreenshots(int count);

  /// Insight card showing old photos count
  ///
  /// In ko, this message translates to:
  /// **'6개월 이전 사진 {count}장'**
  String insightOldPhotos(int count);

  /// Insight card showing large files count
  ///
  /// In ko, this message translates to:
  /// **'10MB 이상 파일 {count}장'**
  String insightLargeFiles(int count);

  /// Start cleaning button label
  ///
  /// In ko, this message translates to:
  /// **'정리 시작'**
  String get startCleaning;

  /// Gallery cleaning session title
  ///
  /// In ko, this message translates to:
  /// **'갤러리 정리'**
  String get cleanSessionTitle;

  /// Undo action label
  ///
  /// In ko, this message translates to:
  /// **'되돌리기'**
  String get undo;

  /// Resume previous session button
  ///
  /// In ko, this message translates to:
  /// **'이어서 정리'**
  String get resumeSession;

  /// Start fresh button
  ///
  /// In ko, this message translates to:
  /// **'처음부터'**
  String get startFresh;

  /// Resume session dialog title
  ///
  /// In ko, this message translates to:
  /// **'이전 세션 발견'**
  String get resumeSessionTitle;

  /// Resume session dialog description
  ///
  /// In ko, this message translates to:
  /// **'이전 정리를 이어서 하시겠습니까?'**
  String get resumeSessionDescription;

  /// Progress label showing reviewed count out of total
  ///
  /// In ko, this message translates to:
  /// **'{reviewed}/{total}장 확인'**
  String progressLabel(int reviewed, int total);

  /// Delete swipe action label
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get deleteAction;

  /// Keep swipe action label
  ///
  /// In ko, this message translates to:
  /// **'보관'**
  String get keepAction;

  /// Favorite swipe action label
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get favoriteAction;

  /// Photo date metadata label
  ///
  /// In ko, this message translates to:
  /// **'촬영일'**
  String get photoDate;

  /// Photo file size metadata label
  ///
  /// In ko, this message translates to:
  /// **'크기'**
  String get photoSize;

  /// Photo dimensions metadata label
  ///
  /// In ko, this message translates to:
  /// **'해상도'**
  String get photoDimensions;

  /// Empty state message when no photos to clean
  ///
  /// In ko, this message translates to:
  /// **'정리할 사진이 없습니다'**
  String get noPhotosToClean;

  /// Completion message when all photos reviewed
  ///
  /// In ko, this message translates to:
  /// **'모든 사진을 확인했습니다!'**
  String get allPhotosCleaned;

  /// Delete queue screen title
  ///
  /// In ko, this message translates to:
  /// **'삭제 대기열'**
  String get deleteQueueTitle;

  /// Total items pending deletion
  ///
  /// In ko, this message translates to:
  /// **'총 {count}장 삭제 예정'**
  String totalToDelete(int count);

  /// Total storage size to be freed
  ///
  /// In ko, this message translates to:
  /// **'{size} 확보 예정'**
  String totalSizeToFree(String size);

  /// Confirm delete button label
  ///
  /// In ko, this message translates to:
  /// **'삭제 확정'**
  String get confirmDelete;

  /// Confirm delete dialog message
  ///
  /// In ko, this message translates to:
  /// **'{count}장의 사진을 영구 삭제하시겠습니까?'**
  String confirmDeleteDialog(int count);

  /// Restore item from delete queue
  ///
  /// In ko, this message translates to:
  /// **'복구'**
  String get restore;

  /// Session summary screen title
  ///
  /// In ko, this message translates to:
  /// **'정리 완료!'**
  String get sessionSummaryTitle;

  /// Total reviewed stat label
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get totalReviewed;

  /// Total deleted stat label
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get totalDeleted;

  /// Total kept stat label
  ///
  /// In ko, this message translates to:
  /// **'보관'**
  String get totalKept;

  /// Total favorited stat label
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get totalFavorited;

  /// Storage freed stat label
  ///
  /// In ko, this message translates to:
  /// **'확보 용량'**
  String get storageFreed;

  /// View delete queue button label
  ///
  /// In ko, this message translates to:
  /// **'삭제 대기열 확인'**
  String get viewDeleteQueue;

  /// Done button label
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get done;

  /// Deletion success snackbar message
  ///
  /// In ko, this message translates to:
  /// **'삭제가 완료되었습니다'**
  String get deleteSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
