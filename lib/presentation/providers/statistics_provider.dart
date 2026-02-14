import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pickture/application/providers/app_providers.dart';
import 'package:pickture/domain/entities/cleaning_statistics.dart';

part 'statistics_provider.g.dart';

@riverpod
class StatisticsNotifier extends _$StatisticsNotifier {
  @override
  FutureOr<CleaningStatistics> build() async {
    final repo = ref.read(statisticsRepositoryProvider);
    return repo.getStatistics();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
