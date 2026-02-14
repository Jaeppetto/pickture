import 'package:drift/drift.dart';

import 'package:pickture/data/datasources/database/app_database.dart' as db_lib;
import 'package:pickture/domain/entities/cleaning_statistics.dart';
import 'package:pickture/domain/repositories/statistics_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  StatisticsRepositoryImpl({required this.db});

  final db_lib.AppDatabase db;

  @override
  Future<CleaningStatistics> getStatistics() async {
    final rows = await db.select(db.cleaningStats).get();
    if (rows.isEmpty) return const CleaningStatistics();

    final sessions = rows.length;
    int reviewed = 0, deleted = 0, kept = 0, favorited = 0;
    int bytesFreed = 0;

    for (final row in rows) {
      reviewed += row.photosReviewed;
      deleted += row.photosDeleted;
      kept += row.photosKept;
      favorited += row.photosFavorited;
      bytesFreed += row.bytesFreed;
    }

    return CleaningStatistics(
      totalSessions: sessions,
      totalReviewed: reviewed,
      totalDeleted: deleted,
      totalKept: kept,
      totalFavorited: favorited,
      totalBytesFreed: bytesFreed,
    );
  }

  @override
  Future<void> recordSession({
    required String sessionId,
    required int reviewed,
    required int deleted,
    required int kept,
    required int favorited,
    required int bytesFreed,
  }) async {
    await db
        .into(db.cleaningStats)
        .insert(
          db_lib.CleaningStatsCompanion.insert(
            sessionId: sessionId,
            photosReviewed: Value(reviewed),
            photosDeleted: Value(deleted),
            photosKept: Value(kept),
            photosFavorited: Value(favorited),
            bytesFreed: Value(bytesFreed),
            completedAt: DateTime.now(),
          ),
        );
  }
}
