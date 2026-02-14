import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:pickture/domain/entities/cleaning_decision.dart';
import 'package:pickture/domain/entities/cleaning_session.dart';

class LocalCleaningSessionDatasource {
  LocalCleaningSessionDatasource({required this.prefs});

  final SharedPreferences prefs;

  static const _sessionKey = 'cleaning_session';
  static const _decisionsKey = 'cleaning_decisions';

  Future<CleaningSession?> getActiveSession() async {
    final json = prefs.getString(_sessionKey);
    if (json == null) return null;
    final session = CleaningSession.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
    if (session.status == SessionStatus.completed) return null;
    return session;
  }

  Future<CleaningSession> createSession(CleaningSession session) async {
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
    await prefs.setString(_decisionsKeyFor(session.id), jsonEncode([]));
    return session;
  }

  Future<void> updateSession(CleaningSession session) async {
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<void> addDecision(String sessionId, CleaningDecision decision) async {
    final decisions = await getDecisions(sessionId);
    decisions.add(decision);
    await _saveDecisions(sessionId, decisions);
  }

  Future<List<CleaningDecision>> getDecisions(String sessionId) async {
    final json = prefs.getString(_decisionsKeyFor(sessionId));
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => CleaningDecision.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CleaningDecision>> getDeleteDecisions(String sessionId) async {
    final decisions = await getDecisions(sessionId);
    return decisions
        .where((d) => d.type == CleaningDecisionType.delete)
        .toList();
  }

  Future<void> removeDecision(String sessionId, String photoId) async {
    final decisions = await getDecisions(sessionId);
    decisions.removeWhere((d) => d.photoId == photoId);
    await _saveDecisions(sessionId, decisions);
  }

  Future<void> clearSession(String sessionId) async {
    await prefs.remove(_sessionKey);
    await prefs.remove(_decisionsKeyFor(sessionId));
  }

  Future<void> _saveDecisions(
    String sessionId,
    List<CleaningDecision> decisions,
  ) async {
    final json = decisions.map((d) => d.toJson()).toList();
    await prefs.setString(_decisionsKeyFor(sessionId), jsonEncode(json));
  }

  String _decisionsKeyFor(String sessionId) => '${_decisionsKey}_$sessionId';
}
