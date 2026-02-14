import 'package:pickture/domain/entities/trash_item.dart';

abstract class TrashRepository {
  Future<List<TrashItem>> getTrashItems();
  Future<void> moveToTrash({
    required String photoId,
    String? sessionId,
    int fileSize = 0,
  });
  Future<void> restoreFromTrash(int trashItemId);
  Future<void> permanentlyDelete(int trashItemId);
  Future<void> emptyTrash();
  Future<void> expireOldItems();
}
