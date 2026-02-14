# Pickture — Implementation History

> 각 Phase별 구현 내역을 기록합니다. 새로운 Phase 구현 시 이 문서를 갱신합니다.

---

## Phase 1: Foundation

**기간:** 프로젝트 초기 셋업
**상태:** Completed

### 구현 내역

| 작업 | 상세 |
|------|------|
| 프로젝트 초기화 | Flutter 프로젝트 생성, SDK ^3.11.0 |
| 폴더 구조 | Clean Architecture (domain/data/presentation/application/core) |
| 디자인 시스템 | Light/Dark 테마, AppColors, AppTextStyles, AppTheme |
| 네비게이션 | GoRouter + ShellRoute 탭 구조 (홈/정리/설정) |
| photo_manager 연동 | 갤러리 접근, 권한 요청/확인, 페이지네이션 |
| i18n 셋업 | ARB 기반 4개 언어 (ko/en/ja/zh), gen-l10n |
| CI/CD | GitHub Actions (pr-check, staging-deploy, release, nightly) |
| 상태 관리 | Riverpod + code generation (@riverpod) |
| 코드 생성 | freezed + json_serializable + riverpod_generator |
| Linting | analysis_options.yaml strict mode |

### 파일 인벤토리

```
lib/
├── app.dart                                    # MaterialApp.router 설정
├── main.dart                                   # 엔트리포인트
├── application/
│   ├── providers/app_providers.dart             # DI (datasource, repository)
│   └── router/app_router.dart                  # GoRouter 탭 라우팅
├── core/
│   ├── constants/app_constants.dart             # 앱 상수 (spacing, radius 등)
│   └── theme/
│       ├── app_colors.dart                     # 색상 토큰 (Light/Dark/Semantic)
│       ├── app_text_styles.dart                # 타이포그래피 스케일
│       └── app_theme.dart                      # ThemeData 빌더
├── data/
│   ├── datasources/local_photo_datasource.dart  # PhotoManager 래핑
│   ├── models/photo_model.dart                 # AssetEntity → Photo 변환
│   └── repositories/photo_repository_impl.dart  # PhotoRepository 구현
├── domain/
│   ├── entities/photo.dart                     # Photo 엔티티 (freezed)
│   └── repositories/photo_repository.dart      # 인터페이스 + PhotoPermissionStatus
├── l10n/
│   ├── app_ko.arb / app_en.arb / app_ja.arb / app_zh.arb
│   └── (generated) app_localizations*.dart
└── presentation/
    ├── providers/photo_permission_provider.dart  # 권한 상태 관리
    ├── screens/
    │   ├── home/home_screen.dart                # 권한 요청 UI
    │   ├── clean/clean_screen.dart              # 플레이스홀더
    │   └── settings/settings_screen.dart        # 플레이스홀더
    └── widgets/main_scaffold.dart               # BottomNavigationBar
```

### 주요 의존성

| 패키지 | 버전 | 용도 |
|--------|------|------|
| flutter_riverpod | ^2.6.1 | 상태 관리 |
| riverpod_annotation | ^2.6.1 | 코드 생성 |
| go_router | ^14.8.1 | 라우팅 |
| photo_manager | ^3.6.3 | 갤러리 접근 |
| photo_manager_image_provider | ^2.2.0 | 이미지 렌더링 |
| fl_chart | ^0.70.2 | 차트 |
| freezed_annotation | ^2.4.4 | 불변 모델 |
| json_annotation | ^4.9.0 | JSON 직렬화 |
| shared_preferences | ^2.3.5 | 로컬 저장소 |

---

## Phase 2: Core Feature

**기간:** 2026-02-14
**상태:** Completed

### 구현 내역

| 작업 | 상세 |
|------|------|
| Domain Layer | 6개 엔티티 (freezed), 1개 리포지토리 인터페이스 신규, 1개 수정 |
| Data Layer | 2개 datasource/repository 신규, 3개 수정, SharedPreferences 기반 세션 저장 |
| 스토리지 대시보드 | 도넛 차트, 기기 저장 공간 바, 인사이트 카드, 정리 예측 |
| 스와이프 정리 UI | 카드 스택, 제스처 판정, 스프링 애니메이션, 햅틱 피드백 |
| 세션 관리 | 시작/이어하기/일시정지/완료, 50장씩 페이지 로딩 |
| 삭제 대기열 | 그리드 썸네일, 개별 복구, 삭제 확정 다이얼로그 |
| 세션 요약 | 통계 그리드, 확보 용량, 삭제 대기열 진입 |
| 라우팅 | /delete-queue/:sessionId, /session-summary/:sessionId (ShellRoute 바깥) |
| i18n | 44개 키 추가 (대시보드 14, 스와이프 15, 삭제/요약 15) |
| 유틸리티 | StorageFormatter (bytes → "1.2 GB") |

### 설계 결정

| 결정 | 이유 |
|------|------|
| **세션 저장: SharedPreferences** | MVP에 충분. 히스토리 필요 시 Phase 3에서 DB 마이그레이션 |
| **결정 목록: 인메모리 + 주기적 저장** | 스와이프마다 I/O 없음. pause/complete/10건마다 persist |
| **카드 프리로드 3장** | 50장씩 페이지 로딩, 10장 남으면 다음 배치 |
| **파일 크기: lazy fetch** | `AssetEntity.originFile` → 개별 조회. 대시보드는 추정치 사용 |
| **Undo: 단일 레벨** | lastDecision만 저장, MVP 범위 |
| **삭제 대기열/요약: ShellRoute 바깥** | 탭바 없이 전체 화면 집중 |
| **기기 저장 공간: placeholder** | iOS/Android API 차이로 추후 플랫폼 채널 구현 예정 |

### 신규 파일 (31개)

```
lib/
├── core/
│   └── utils/storage_formatter.dart                          # formatBytes()
├── domain/
│   ├── entities/
│   │   ├── cleaning_filter.dart                              # CleaningFilter (freezed)
│   │   ├── cleaning_session.dart                             # CleaningSession + SessionStatus
│   │   ├── cleaning_decision.dart                            # CleaningDecision + CleaningDecisionType
│   │   ├── storage_info.dart                                 # StorageInfo (freezed)
│   │   ├── insight_card.dart                                 # InsightCard + InsightType
│   │   └── cleaning_state.dart                               # CleaningState (freezed)
│   └── repositories/
│       └── cleaning_session_repository.dart                  # 세션/결정 CRUD 인터페이스
├── data/
│   ├── datasources/
│   │   └── local_cleaning_session_datasource.dart            # SharedPreferences 기반
│   └── repositories/
│       └── cleaning_session_repository_impl.dart             # 구현체
├── presentation/
│   ├── providers/
│   │   ├── storage_analysis_provider.dart                    # StorageInfo 비동기 로딩
│   │   ├── insights_provider.dart                            # InsightCard 리스트
│   │   ├── cleaning_session_provider.dart                    # 세션 전체 상태 관리
│   │   └── delete_queue_provider.dart                        # 삭제 대기열 관리
│   ├── screens/clean/
│   │   ├── delete_queue_screen.dart                          # 삭제 대기열 화면
│   │   └── session_summary_screen.dart                       # 세션 요약 화면
│   └── widgets/
│       ├── dashboard/
│       │   ├── storage_header_card.dart                      # 총 사진/동영상 수 + 용량
│       │   ├── storage_donut_chart.dart                      # fl_chart PieChart
│       │   ├── device_storage_bar.dart                       # 기기 저장 공간 바
│       │   ├── cleaning_prediction_card.dart                 # "정리하면 X GB 확보"
│       │   └── insight_card_widget.dart                      # 인사이트 카드 (탭 → 정리)
│       ├── swipe/
│       │   ├── swipe_direction.dart                          # SwipeDirection enum
│       │   ├── swipe_card_stack.dart                         # 카드 스택 + 제스처
│       │   ├── swipe_card.dart                               # 개별 카드 (AssetEntityImage)
│       │   ├── swipe_overlay.dart                            # 드래그 중 색상 오버레이
│       │   ├── photo_detail_overlay.dart                     # 탭 시 메타데이터
│       │   ├── swipe_action_buttons.dart                     # 하단 4버튼
│       │   ├── cleaning_progress_bar.dart                    # 진행률 바
│       │   └── session_resume_dialog.dart                    # 이어하기 다이얼로그
│       └── delete_queue/
│           ├── delete_queue_item.dart                        # 그리드 셀 + 복구
│           └── confirm_delete_button.dart                    # 확인 다이얼로그
```

### 수정 파일 (11개)

| 파일 | 변경 내용 |
|------|----------|
| `domain/repositories/photo_repository.dart` | +5 메서드 (getStorageInfo, getInsights, getFilteredPhotos, getFilteredCount, deletePhotos) |
| `data/models/photo_model.dart` | +toPhotoWithSize() async 메서드 |
| `data/datasources/local_photo_datasource.dart` | +5 메서드 구현 (스토리지 분석, 인사이트, 필터, 삭제) |
| `data/repositories/photo_repository_impl.dart` | +5 메서드 위임 |
| `application/providers/app_providers.dart` | +sharedPreferencesProvider, +cleaningSession datasource/repository providers |
| `application/router/app_router.dart` | +delete-queue, +session-summary 라우트 (ShellRoute 바깥) |
| `core/constants/app_constants.dart` | +스와이프 임계값, +카드 스택, +스토리지, +세션 상수 |
| `presentation/screens/home/home_screen.dart` | 전면 재작성 → 스토리지 대시보드 |
| `presentation/screens/clean/clean_screen.dart` | 전면 재작성 → 스와이프 정리 UI |
| `main.dart` | SharedPreferences 초기화 + ProviderScope.overrides |
| `l10n/app_*.arb (x4)` | +44개 i18n 키 (대시보드/스와이프/삭제/요약) |

### i18n 키 목록

**대시보드 (14개)**
`dashboardTitle`, `totalPhotosVideos({count})`, `totalStorage`, `photos`, `videos`, `screenshots`, `other`, `deviceStorage`, `freeSpace`, `cleaningPrediction({size})`, `insightScreenshots({count})`, `insightOldPhotos({count})`, `insightLargeFiles({count})`, `startCleaning`

**스와이프 (15개)**
`cleanSessionTitle`, `undo`, `resumeSession`, `startFresh`, `resumeSessionTitle`, `resumeSessionDescription`, `progressLabel({reviewed},{total})`, `deleteAction`, `keepAction`, `favoriteAction`, `photoDate`, `photoSize`, `photoDimensions`, `noPhotosToClean`, `allPhotosCleaned`

**삭제 대기열 / 세션 요약 (15개)**
`deleteQueueTitle`, `totalToDelete({count})`, `totalSizeToFree({size})`, `confirmDelete`, `confirmDeleteDialog({count})`, `restore`, `sessionSummaryTitle`, `totalReviewed`, `totalDeleted`, `totalKept`, `totalFavorited`, `storageFreed`, `viewDeleteQueue`, `done`, `deleteSuccess`

### 검증 결과

| 항목 | 결과 |
|------|------|
| `build_runner build` | 32 outputs 성공 |
| `flutter gen-l10n` | 성공 |
| `dart analyze` | 0 issues |
| `dart format --set-exit-if-changed` | 0 changed (76 files) |
| `flutter test` | All tests passed |

### 유저 플로우

```
홈 (대시보드)
├── StorageHeaderCard — 총 사진/동영상 수 + 전체 용량
├── DonutChartCard — 카테고리별 분포 (사진/동영상/스크린샷/기타)
├── DeviceStorageBar — 기기 저장 공간 비율
├── CleaningPredictionCard — "정리하면 X GB 확보 가능"
├── InsightCards — 스크린샷/오래된 사진/대용량 파일 (탭 → /clean)
└── StartCleaningButton → /clean

정리 (/clean)
├── 세션 없음 → 시작 화면 (+ 이전 세션 감지 시 resume dialog)
├── 세션 활성 →
│   ├── CleaningProgressBar (reviewed/total)
│   ├── SwipeCardStack (2~3장, 제스처 판정, 스프링 애니메이션)
│   └── SwipeActionButtons (삭제/보관/즐겨찾기/되돌리기)
└── 모든 사진 확인 → completeSession() → /session-summary/:id

세션 요약 (/session-summary/:id)
├── 축하 아이콘 + "정리 완료!"
├── 통계 그리드 (확인/삭제/보관/즐겨찾기)
├── 확보 용량
├── "삭제 대기열 확인" → /delete-queue/:id
└── "완료" → /home

삭제 대기열 (/delete-queue/:id)
├── 헤더 ("총 N장 삭제 예정")
├── GridView (3열 썸네일, 각각 복구 버튼)
└── ConfirmDeleteButton → 확인 다이얼로그 → 삭제 확정 → /home
```

---

## Phase 3: Polish & Safety (예정)

**상태:** Not Started

### 예정 작업

| 작업 | 상세 |
|------|------|
| 휴지통 | 복구/영구삭제/30일 자동만료 |
| 온보딩 튜토리얼 | 3장 스와이프 가이드 |
| 정리 통계 | 누적 기록 (총 정리 사진, 확보 용량) |
| 정리 리마인더 | flutter_local_notifications, 주 1회 알림 |
| 애니메이션 폴리시 | 삭제 시 파티클, 세션 완료 컨페티, 차트 빌드업 |
| 햅틱 폴리시 | Reduce Motion 대응, 햅틱 설정 토글 |
| DB 마이그레이션 | SharedPreferences → drift/isar (세션 히스토리) |
| 기기 저장 공간 | 플랫폼 채널로 실제 값 조회 |

---

## Phase 4: Testing & Launch (예정)

**상태:** Not Started

### 예정 작업

| 작업 | 상세 |
|------|------|
| Unit Test | Domain 엔티티, Use Case, Provider 로직 (커버리지 60%) |
| Widget Test | 스와이프 카드, 대시보드 위젯, 삭제 대기열 |
| Integration Test | 정리 세션 전체 플로우, 권한 → 대시보드 → 정리 |
| Golden Test | 스와이프 카드, 대시보드 스냅샷 |
| 성능 최적화 | 대용량 갤러리 (10만+장), 메모리 프로파일링 |
| App Store 준비 | 메타데이터, 스크린샷, 프라이버시 정책 |
| 문서화 | README, CHANGELOG, 스토어 설명 |

---

## Appendix: Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐  │
│  │ Screens  │  │ Widgets  │  │ Providers(@riverpod)│ │
│  └────┬─────┘  └────┬─────┘  └────────┬──────────┘  │
│       │              │                  │             │
├───────┼──────────────┼──────────────────┼─────────────┤
│       │         Application Layer       │             │
│  ┌────┴─────┐  ┌────────────────────────┴──────────┐  │
│  │ Router   │  │  App Providers (DI)               │  │
│  └──────────┘  └────────────────────────┬──────────┘  │
│                                         │             │
├─────────────────────────────────────────┼─────────────┤
│                  Domain Layer           │             │
│  ┌──────────┐  ┌────────────────────────┴──────────┐  │
│  │ Entities │  │  Repository Interfaces            │  │
│  │ (freezed)│  │  (PhotoRepository,                │  │
│  │          │  │   CleaningSessionRepository)      │  │
│  └──────────┘  └────────────────────────┬──────────┘  │
│                                         │             │
├─────────────────────────────────────────┼─────────────┤
│                  Data Layer             │             │
│  ┌──────────┐  ┌──────────┐  ┌─────────┴──────────┐  │
│  │ Models   │  │Datasources│ │ Repository Impls    │  │
│  │(extension)│ │(PhotoMgr, │ │                     │  │
│  │          │  │ SharedPref)│ │                     │  │
│  └──────────┘  └──────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### 의존성 방향

```
Presentation → Application → Domain ← Data
                                ↑        │
                                └────────┘
```

- Domain은 외부 의존성 없음 (순수 Dart)
- Data는 Domain 인터페이스를 구현
- Presentation은 Domain 엔티티를 직접 사용
- Application은 Provider를 통해 DI 연결
