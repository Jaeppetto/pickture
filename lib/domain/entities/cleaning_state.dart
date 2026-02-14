import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:pickture/domain/entities/cleaning_decision.dart';
import 'package:pickture/domain/entities/cleaning_session.dart';
import 'package:pickture/domain/entities/photo.dart';

part 'cleaning_state.freezed.dart';
part 'cleaning_state.g.dart';

@freezed
abstract class CleaningState with _$CleaningState {
  const factory CleaningState({
    required CleaningSession session,
    required List<Photo> photoQueue,
    required int currentIndex,
    required List<CleaningDecision> decisions,
    CleaningDecision? lastDecision,
    @Default(0) int comboCount,
  }) = _CleaningState;

  factory CleaningState.fromJson(Map<String, dynamic> json) =>
      _$CleaningStateFromJson(json);
}
