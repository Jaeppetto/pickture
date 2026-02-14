import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pickture/application/providers/app_providers.dart';
import 'package:pickture/domain/entities/insight_card.dart';

part 'insights_provider.g.dart';

@riverpod
FutureOr<List<InsightCard>> insights(InsightsRef ref) async {
  final repo = ref.read(photoRepositoryProvider);
  return repo.getInsights();
}
