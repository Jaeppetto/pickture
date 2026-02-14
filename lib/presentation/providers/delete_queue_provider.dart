import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pickture/application/providers/app_providers.dart';
import 'package:pickture/domain/entities/cleaning_decision.dart';

part 'delete_queue_provider.g.dart';

@riverpod
class DeleteQueue extends _$DeleteQueue {
  @override
  FutureOr<List<CleaningDecision>> build(String sessionId) async {
    final repo = ref.read(cleaningSessionRepositoryProvider);
    return repo.getDeleteDecisions(sessionId);
  }

  Future<void> restorePhoto(String photoId) async {
    final repo = ref.read(cleaningSessionRepositoryProvider);
    await repo.removeDecision(sessionId, photoId);
    final current = state.value ?? [];
    state = AsyncData(current.where((d) => d.photoId != photoId).toList());
  }

  Future<bool> confirmDeletion() async {
    final current = state.value;
    if (current == null || current.isEmpty) return false;

    final trashRepo = ref.read(trashRepositoryProvider);

    // Move to trash instead of permanent deletion
    for (final decision in current) {
      await trashRepo.moveToTrash(
        photoId: decision.photoId,
        sessionId: sessionId,
      );
    }

    final sessionRepo = ref.read(cleaningSessionRepositoryProvider);
    await sessionRepo.clearSession(sessionId);
    state = const AsyncData([]);

    return true;
  }
}
