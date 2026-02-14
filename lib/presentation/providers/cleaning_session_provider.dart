import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pickture/application/providers/app_providers.dart';
import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/domain/entities/cleaning_decision.dart';
import 'package:pickture/domain/entities/cleaning_session.dart';
import 'package:pickture/domain/entities/cleaning_state.dart';
import 'package:pickture/domain/entities/photo.dart';

part 'cleaning_session_provider.g.dart';

@riverpod
class CleaningSessionNotifier extends _$CleaningSessionNotifier {
  int _currentPage = 0;
  int _persistCounter = 0;

  @override
  FutureOr<CleaningState?> build() async {
    return null;
  }

  Future<CleaningSession?> checkActiveSession() async {
    final repo = ref.read(cleaningSessionRepositoryProvider);
    return repo.getActiveSession();
  }

  Future<void> startSession() async {
    state = const AsyncLoading();
    _currentPage = 0;
    _persistCounter = 0;

    final photoRepo = ref.read(photoRepositoryProvider);
    final sessionRepo = ref.read(cleaningSessionRepositoryProvider);

    final totalPhotos = await photoRepo.getTotalCount();
    final session = CleaningSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startedAt: DateTime.now(),
      status: SessionStatus.active,
      totalPhotos: totalPhotos,
      reviewedCount: 0,
    );
    await sessionRepo.createSession(session);

    final photos = await photoRepo.getPhotos(
      page: _currentPage,
      pageSize: AppConstants.photoPageSize,
    );

    state = AsyncData(
      CleaningState(
        session: session,
        photoQueue: photos,
        currentIndex: 0,
        decisions: [],
      ),
    );
  }

  Future<void> resumeSession() async {
    state = const AsyncLoading();
    _persistCounter = 0;

    final sessionRepo = ref.read(cleaningSessionRepositoryProvider);
    final photoRepo = ref.read(photoRepositoryProvider);

    final session = await sessionRepo.getActiveSession();
    if (session == null) {
      state = const AsyncData(null);
      return;
    }

    final decisions = await sessionRepo.getDecisions(session.id);
    final reviewedIds = decisions.map((d) => d.photoId).toSet();

    // Calculate start page based on reviewed count
    _currentPage = reviewedIds.length ~/ AppConstants.photoPageSize;

    // Load pages until we have enough unreviewed photos
    final remainingPhotos = <Photo>[];
    const minPhotos = AppConstants.nextBatchThreshold;
    while (remainingPhotos.length < minPhotos) {
      final photos = await photoRepo.getPhotos(
        page: _currentPage,
        pageSize: AppConstants.photoPageSize,
      );
      if (photos.isEmpty) break;

      final filtered = photos.where((p) => !reviewedIds.contains(p.id));
      remainingPhotos.addAll(filtered);
      _currentPage++;
    }

    state = AsyncData(
      CleaningState(
        session: session,
        photoQueue: remainingPhotos,
        currentIndex: 0,
        decisions: decisions,
      ),
    );
  }

  Future<void> makeDecision(CleaningDecisionType type) async {
    final current = state.value;
    if (current == null) return;
    if (current.currentIndex >= current.photoQueue.length) return;

    final photo = current.photoQueue[current.currentIndex];
    final decision = CleaningDecision(
      photoId: photo.id,
      type: type,
      decidedAt: DateTime.now(),
    );

    final newDecisions = [...current.decisions, decision];
    final newIndex = current.currentIndex + 1;
    final newSession = current.session.copyWith(
      reviewedCount: current.session.reviewedCount + 1,
    );

    // Track combo for consecutive deletes
    final newCombo = type == CleaningDecisionType.delete
        ? current.comboCount + 1
        : 0;

    state = AsyncData(
      current.copyWith(
        session: newSession,
        currentIndex: newIndex,
        decisions: newDecisions,
        lastDecision: decision,
        comboCount: newCombo,
      ),
    );

    // Persist periodically
    _persistCounter++;
    if (_persistCounter >= AppConstants.persistInterval) {
      await _persist();
      _persistCounter = 0;
    }

    // Load next batch if needed
    final remaining = current.photoQueue.length - newIndex;
    if (remaining <= AppConstants.nextBatchThreshold) {
      await _loadNextBatch();
    }
  }

  Future<void> undoLastDecision() async {
    final current = state.value;
    if (current == null) return;
    if (current.lastDecision == null) return;
    if (current.currentIndex <= 0) return;

    final newDecisions = [...current.decisions]
      ..removeWhere((d) => d.photoId == current.lastDecision!.photoId);

    final newSession = current.session.copyWith(
      reviewedCount: (current.session.reviewedCount - 1).clamp(
        0,
        current.session.totalPhotos,
      ),
    );

    state = AsyncData(
      current.copyWith(
        session: newSession,
        currentIndex: current.currentIndex - 1,
        decisions: newDecisions,
        lastDecision: null,
      ),
    );
  }

  Future<void> pauseSession() async {
    final current = state.value;
    if (current == null) return;

    final newSession = current.session.copyWith(status: SessionStatus.paused);

    state = AsyncData(current.copyWith(session: newSession));
    await _persist();
  }

  Future<void> completeSession() async {
    final current = state.value;
    if (current == null) return;

    final newSession = current.session.copyWith(
      status: SessionStatus.completed,
      completedAt: DateTime.now(),
    );

    state = AsyncData(current.copyWith(session: newSession));
    await _persist();

    // Record statistics
    final statsRepo = ref.read(statisticsRepositoryProvider);
    final deleted = current.decisions
        .where((d) => d.type == CleaningDecisionType.delete)
        .length;
    final kept = current.decisions
        .where((d) => d.type == CleaningDecisionType.keep)
        .length;
    final favorited = current.decisions
        .where((d) => d.type == CleaningDecisionType.favorite)
        .length;
    await statsRepo.recordSession(
      sessionId: current.session.id,
      reviewed: current.session.reviewedCount,
      deleted: deleted,
      kept: kept,
      favorited: favorited,
      bytesFreed: 0,
    );
  }

  Future<void> _loadNextBatch() async {
    final current = state.value;
    if (current == null) return;

    _currentPage++;
    final photoRepo = ref.read(photoRepositoryProvider);
    final newPhotos = await photoRepo.getPhotos(
      page: _currentPage,
      pageSize: AppConstants.photoPageSize,
    );

    if (newPhotos.isEmpty) return;

    final reviewedIds = current.decisions.map((d) => d.photoId).toSet();
    final filtered = newPhotos
        .where((p) => !reviewedIds.contains(p.id))
        .toList();

    state = AsyncData(
      current.copyWith(photoQueue: [...current.photoQueue, ...filtered]),
    );
  }

  Future<void> _persist() async {
    final current = state.value;
    if (current == null) return;

    final sessionRepo = ref.read(cleaningSessionRepositoryProvider);
    await sessionRepo.updateSession(current.session);
    await sessionRepo.saveAllDecisions(current.session.id, current.decisions);
  }
}
