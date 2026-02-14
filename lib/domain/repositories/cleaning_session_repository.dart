import 'package:pickture/domain/entities/cleaning_decision.dart';
import 'package:pickture/domain/entities/cleaning_session.dart';

abstract class CleaningSessionRepository {
  Future<CleaningSession?> getActiveSession();
  Future<CleaningSession> createSession(CleaningSession session);
  Future<void> updateSession(CleaningSession session);
  Future<void> addDecision(String sessionId, CleaningDecision decision);
  Future<List<CleaningDecision>> getDecisions(String sessionId);
  Future<List<CleaningDecision>> getDeleteDecisions(String sessionId);
  Future<void> removeDecision(String sessionId, String photoId);
  Future<void> saveAllDecisions(
    String sessionId,
    List<CleaningDecision> decisions,
  );
  Future<void> clearSession(String sessionId);
}
