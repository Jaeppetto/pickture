import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/utils/storage_formatter.dart';
import 'package:pickture/l10n/app_localizations.dart';
import 'package:pickture/presentation/providers/statistics_provider.dart';

class StatisticsCard extends ConsumerWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final statsAsync = ref.watch(statisticsNotifierProvider);

    return Card(
      margin: const EdgeInsets.all(AppConstants.spacing16),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: statsAsync.when(
          data: (stats) {
            if (stats.totalSessions == 0) {
              return Column(
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  Text(l10n.statNoData, style: theme.textTheme.bodyMedium),
                  Text(
                    l10n.statStartCleaning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.statisticsTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppConstants.spacing16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: l10n.statTotalSessions,
                      value: '${stats.totalSessions}',
                    ),
                    _StatItem(
                      label: l10n.statTotalReviewed,
                      value: '${stats.totalReviewed}',
                    ),
                    _StatItem(
                      label: l10n.statTotalCleaned,
                      value: '${stats.totalDeleted}',
                    ),
                    _StatItem(
                      label: l10n.statTotalFreed,
                      value: StorageFormatter.formatBytes(
                        stats.totalBytesFreed,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.spacing4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
