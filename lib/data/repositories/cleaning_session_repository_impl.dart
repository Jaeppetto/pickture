import 'package:pickture/data/datasources/drift_cleaning_session_datasource.dart';
import 'package:pickture/domain/entities/cleaning_decision.dart';
import 'package:pickture/domain/entities/cleaning_session.dart';
import 'package:pickture/domain/repositories/cleaning_session_repository.dart';

class CleaningSessionRepositoryImpl implements CleaningSessionRepository {
  CleaningSessionRepositoryImpl({required this.datasource});

  final DriftCleaningSessionDatasource datasource;

  @override
  Future<CleaningSession?> getActiveSession() {
    return datasource.getActiveSession();
  }

  @override
  Future<CleaningSession> createSession(CleaningSession session) {
    return datasource.createSession(session);
  }

  @override
  Future<void> updateSession(CleaningSession session) {
    return datasource.updateSession(session);
  }

  @override
  Future<void> addDecision(String sessionId, CleaningDecision decision) {
    return datasource.addDecision(sessionId, decision);
  }

  @override
  Future<List<CleaningDecision>> getDecisions(String sessionId) {
    return datasource.getDecisions(sessionId);
  }

  @override
  Future<List<CleaningDecision>> getDeleteDecisions(String sessionId) {
    return datasource.getDeleteDecisions(sessionId);
  }

  @override
  Future<void> removeDecision(String sessionId, String photoId) {
    return datasource.removeDecision(sessionId, photoId);
  }

  @override
  Future<void> saveAllDecisions(
    String sessionId,
    List<CleaningDecision> decisions,
  ) {
    return datasource.saveAllDecisions(sessionId, decisions);
  }

  @override
  Future<void> clearSession(String sessionId) {
    return datasource.clearSession(sessionId);
  }
}
