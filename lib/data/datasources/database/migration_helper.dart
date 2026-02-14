import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pickture/data/datasources/database/app_database.dart';

class MigrationHelper {
  MigrationHelper({required this.db, required this.prefs});

  final AppDatabase db;
  final SharedPreferences prefs;

  static const _migratedKey = 'db_migrated_v1';
  static const _sessionKey = 'cleaning_session';
  static const _decisionsKey = 'cleaning_decisions';

  Future<void> migrateIfNeeded() async {
    if (prefs.getBool(_migratedKey) == true) return;

    await _migrateSession();
    await prefs.setBool(_migratedKey, true);
  }

  Future<void> _migrateSession() async {
    final sessionJson = prefs.getString(_sessionKey);
    if (sessionJson == null) return;

    final session = jsonDecode(sessionJson) as Map<String, dynamic>;
    final sessionId = session['id'] as String;

    await db
        .into(db.cleaningSessions)
        .insertOnConflictUpdate(
          CleaningSessionsCompanion.insert(
            id: sessionId,
            startedAt: DateTime.parse(session['startedAt'] as String),
            status: session['status'] as String,
            totalPhotos: session['totalPhotos'] as int,
            reviewedCount: Value(session['reviewedCount'] as int? ?? 0),
            completedAt: session['completedAt'] != null
                ? Value(DateTime.parse(session['completedAt'] as String))
                : const Value.absent(),
          ),
        );

    // Migrate decisions
    final decisionsJson = prefs.getString('${_decisionsKey}_$sessionId');
    if (decisionsJson != null) {
      final decisions = jsonDecode(decisionsJson) as List<dynamic>;
      for (final d in decisions) {
        final decision = d as Map<String, dynamic>;
        await db
            .into(db.cleaningDecisions)
            .insert(
              CleaningDecisionsCompanion.insert(
                sessionId: sessionId,
                photoId: decision['photoId'] as String,
                type: decision['type'] as String,
                decidedAt: DateTime.parse(decision['decidedAt'] as String),
              ),
            );
      }
    }
  }
}
