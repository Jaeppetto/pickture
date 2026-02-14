import 'package:drift/drift.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/data/datasources/database/app_database.dart' as db_lib;
import 'package:pickture/domain/entities/trash_item.dart';

class DriftTrashDatasource {
  DriftTrashDatasource({required this.db});

  final db_lib.AppDatabase db;

  Future<List<TrashItem>> getTrashItems() async {
    final query = db.select(db.trashItems)
      ..orderBy([(t) => OrderingTerm.desc(t.trashedAt)]);

    final rows = await query.get();
    return rows.map(_mapTrashItem).toList();
  }

  Future<void> moveToTrash({
    required String photoId,
    String? sessionId,
    int fileSize = 0,
  }) async {
    final now = DateTime.now();
    await db
        .into(db.trashItems)
        .insert(
          db_lib.TrashItemsCompanion.insert(
            photoId: photoId,
            sessionId: Value(sessionId),
            fileSize: Value(fileSize),
            trashedAt: now,
            expiresAt: now.add(
              const Duration(days: AppConstants.trashRetentionDays),
            ),
          ),
        );
  }

  Future<void> restoreFromTrash(int trashItemId) async {
    await (db.delete(
      db.trashItems,
    )..where((t) => t.id.equals(trashItemId))).go();
  }

  Future<void> permanentlyDelete(int trashItemId) async {
    await (db.delete(
      db.trashItems,
    )..where((t) => t.id.equals(trashItemId))).go();
  }

  Future<void> emptyTrash() async {
    await db.delete(db.trashItems).go();
  }

  Future<void> expireOldItems() async {
    final now = DateTime.now();
    await (db.delete(
      db.trashItems,
    )..where((t) => t.expiresAt.isSmallerOrEqualValue(now))).go();
  }

  TrashItem _mapTrashItem(db_lib.TrashItem row) {
    return TrashItem(
      id: row.id,
      photoId: row.photoId,
      sessionId: row.sessionId,
      fileSize: row.fileSize,
      trashedAt: row.trashedAt,
      expiresAt: row.expiresAt,
    );
  }
}
