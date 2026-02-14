import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pickture/application/providers/app_providers.dart';
import 'package:pickture/domain/entities/trash_item.dart';

part 'trash_provider.g.dart';

@riverpod
class TrashNotifier extends _$TrashNotifier {
  @override
  FutureOr<List<TrashItem>> build() async {
    final repo = ref.read(trashRepositoryProvider);
    await repo.expireOldItems();
    return repo.getTrashItems();
  }

  Future<void> restore(int trashItemId) async {
    final repo = ref.read(trashRepositoryProvider);
    await repo.restoreFromTrash(trashItemId);
    ref.invalidateSelf();
  }

  Future<void> permanentlyDelete(int trashItemId) async {
    final repo = ref.read(trashRepositoryProvider);
    await repo.permanentlyDelete(trashItemId);
    ref.invalidateSelf();
  }

  Future<void> emptyTrash() async {
    final repo = ref.read(trashRepositoryProvider);
    await repo.emptyTrash();
    ref.invalidateSelf();
  }
}
