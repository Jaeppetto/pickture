import 'package:freezed_annotation/freezed_annotation.dart';

part 'cleaning_statistics.freezed.dart';
part 'cleaning_statistics.g.dart';

@freezed
abstract class CleaningStatistics with _$CleaningStatistics {
  const factory CleaningStatistics({
    @Default(0) int totalSessions,
    @Default(0) int totalReviewed,
    @Default(0) int totalDeleted,
    @Default(0) int totalKept,
    @Default(0) int totalFavorited,
    @Default(0) int totalBytesFreed,
  }) = _CleaningStatistics;

  factory CleaningStatistics.fromJson(Map<String, dynamic> json) =>
      _$CleaningStatisticsFromJson(json);
}
