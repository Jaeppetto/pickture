import 'package:drift/drift.dart';

import 'package:pickture/data/datasources/database/app_database.dart' as db_lib;
import 'package:pickture/domain/entities/cleaning_decision.dart';
import 'package:pickture/domain/entities/cleaning_session.dart';

class DriftCleaningSessionDatasource {
  DriftCleaningSessionDatasource({required this.db});

  final db_lib.AppDatabase db;

  Future<CleaningSession?> getActiveSession() async {
    final query = db.select(db.cleaningSessions)
      ..where((t) => t.status.isIn(['active', 'paused']))
      ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapSession(row);
  }

  Future<CleaningSession> createSession(CleaningSession session) async {
    await db
        .into(db.cleaningSessions)
        .insert(
          db_lib.CleaningSessionsCompanion.insert(
            id: session.id,
            startedAt: session.startedAt,
            status: session.status.name,
            totalPhotos: session.totalPhotos,
            reviewedCount: Value(session.reviewedCount),
            completedAt: session.completedAt != null
                ? Value(session.completedAt!)
                : const Value.absent(),
          ),
        );
    return session;
  }

  Future<void> updateSession(CleaningSession session) async {
    await (db.update(
      db.cleaningSessions,
    )..where((t) => t.id.equals(session.id))).write(
      db_lib.CleaningSessionsCompanion(
        status: Value(session.status.name),
        reviewedCount: Value(session.reviewedCount),
        completedAt: session.completedAt != null
            ? Value(session.completedAt!)
            : const Value.absent(),
      ),
    );
  }

  Future<void> addDecision(String sessionId, CleaningDecision decision) async {
    await db
        .into(db.cleaningDecisions)
        .insert(
          db_lib.CleaningDecisionsCompanion.insert(
            sessionId: sessionId,
            photoId: decision.photoId,
            type: decision.type.name,
            decidedAt: decision.decidedAt,
          ),
        );
  }

  Future<List<CleaningDecision>> getDecisions(String sessionId) async {
    final query = db.select(db.cleaningDecisions)
      ..where((t) => t.sessionId.equals(sessionId));

    final rows = await query.get();
    return rows.map<CleaningDecision>(_mapDecision).toList();
  }

  Future<List<CleaningDecision>> getDeleteDecisions(String sessionId) async {
    final query = db.select(db.cleaningDecisions)
      ..where((t) => t.sessionId.equals(sessionId) & t.type.equals('delete'));

    final rows = await query.get();
    return rows.map<CleaningDecision>(_mapDecision).toList();
  }

  Future<void> removeDecision(String sessionId, String photoId) async {
    await (db.delete(db.cleaningDecisions)..where(
          (t) => t.sessionId.equals(sessionId) & t.photoId.equals(photoId),
        ))
        .go();
  }

  Future<void> saveAllDecisions(
    String sessionId,
    List<CleaningDecision> decisions,
  ) async {
    await db.transaction(() async {
      await (db.delete(
        db.cleaningDecisions,
      )..where((t) => t.sessionId.equals(sessionId))).go();

      for (final decision in decisions) {
        await db
            .into(db.cleaningDecisions)
            .insert(
              db_lib.CleaningDecisionsCompanion.insert(
                sessionId: sessionId,
                photoId: decision.photoId,
                type: decision.type.name,
                decidedAt: decision.decidedAt,
              ),
            );
      }
    });
  }

  Future<void> clearSession(String sessionId) async {
    await db.transaction(() async {
      await (db.delete(
        db.cleaningDecisions,
      )..where((t) => t.sessionId.equals(sessionId))).go();
      await (db.delete(
        db.cleaningSessions,
      )..where((t) => t.id.equals(sessionId))).go();
    });
  }

  CleaningSession _mapSession(db_lib.CleaningSession row) {
    return CleaningSession(
      id: row.id,
      startedAt: row.startedAt,
      status: SessionStatus.values.byName(row.status),
      totalPhotos: row.totalPhotos,
      reviewedCount: row.reviewedCount,
      completedAt: row.completedAt,
    );
  }

  CleaningDecision _mapDecision(db_lib.CleaningDecision row) {
    return CleaningDecision(
      photoId: row.photoId,
      type: CleaningDecisionType.values.byName(row.type),
      decidedAt: row.decidedAt,
    );
  }
}
