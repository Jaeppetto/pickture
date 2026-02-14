import 'package:pickture/domain/entities/cleaning_statistics.dart';

abstract class StatisticsRepository {
  Future<CleaningStatistics> getStatistics();
  Future<void> recordSession({
    required String sessionId,
    required int reviewed,
    required int deleted,
    required int kept,
    required int favorited,
    required int bytesFreed,
  });
}
