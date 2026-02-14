import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:pickture/domain/entities/cleaning_filter.dart';

part 'cleaning_session.freezed.dart';
part 'cleaning_session.g.dart';

enum SessionStatus { active, paused, completed }

@freezed
abstract class CleaningSession with _$CleaningSession {
  const factory CleaningSession({
    required String id,
    required DateTime startedAt,
    required SessionStatus status,
    required int totalPhotos,
    required int reviewedCount,
    CleaningFilter? filter,
    DateTime? completedAt,
  }) = _CleaningSession;

  factory CleaningSession.fromJson(Map<String, dynamic> json) =>
      _$CleaningSessionFromJson(json);
}
