import 'package:freezed_annotation/freezed_annotation.dart';

part 'cleaning_decision.freezed.dart';
part 'cleaning_decision.g.dart';

enum CleaningDecisionType { delete, keep, favorite }

@freezed
abstract class CleaningDecision with _$CleaningDecision {
  const factory CleaningDecision({
    required String photoId,
    required CleaningDecisionType type,
    required DateTime decidedAt,
  }) = _CleaningDecision;

  factory CleaningDecision.fromJson(Map<String, dynamic> json) =>
      _$CleaningDecisionFromJson(json);
}
