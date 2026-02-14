import 'package:pickture/data/datasources/drift_trash_datasource.dart';
import 'package:pickture/domain/entities/trash_item.dart';
import 'package:pickture/domain/repositories/trash_repository.dart';

class TrashRepositoryImpl implements TrashRepository {
  TrashRepositoryImpl({required this.datasource});

  final DriftTrashDatasource datasource;

  @override
  Future<List<TrashItem>> getTrashItems() {
    return datasource.getTrashItems();
  }

  @override
  Future<void> moveToTrash({
    required String photoId,
    String? sessionId,
    int fileSize = 0,
  }) {
    return datasource.moveToTrash(
      photoId: photoId,
      sessionId: sessionId,
      fileSize: fileSize,
    );
  }

  @override
  Future<void> restoreFromTrash(int trashItemId) {
    return datasource.restoreFromTrash(trashItemId);
  }

  @override
  Future<void> permanentlyDelete(int trashItemId) {
    return datasource.permanentlyDelete(trashItemId);
  }

  @override
  Future<void> emptyTrash() {
    return datasource.emptyTrash();
  }

  @override
  Future<void> expireOldItems() {
    return datasource.expireOldItems();
  }
}
