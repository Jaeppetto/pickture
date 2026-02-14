import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/theme/app_colors.dart';
import 'package:pickture/domain/entities/storage_info.dart';
import 'package:pickture/l10n/app_localizations.dart';

class StorageDonutChart extends StatelessWidget {
  const StorageDonutChart({super.key, required this.info});

  final StorageInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final total =
        info.totalPhotos +
        info.totalVideos +
        info.totalScreenshots +
        info.totalOther;

    if (total == 0) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: _buildSections(total),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Legend(
                  color: theme.colorScheme.primary,
                  label: l10n.photos,
                  count: info.totalPhotos,
                ),
                _Legend(
                  color: AppColors.favorite,
                  label: l10n.videos,
                  count: info.totalVideos,
                ),
                _Legend(
                  color: AppColors.keep,
                  label: l10n.screenshots,
                  count: info.totalScreenshots,
                ),
                _Legend(
                  color: AppColors.delete,
                  label: l10n.other,
                  count: info.totalOther,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(int total) {
    return [
      PieChartSectionData(
        value: info.totalPhotos.toDouble(),
        color: AppColors.lightPrimary,
        radius: 30,
        showTitle: false,
      ),
      PieChartSectionData(
        value: info.totalVideos.toDouble(),
        color: AppColors.favorite,
        radius: 30,
        showTitle: false,
      ),
      PieChartSectionData(
        value: info.totalScreenshots.toDouble(),
        color: AppColors.keep,
        radius: 30,
        showTitle: false,
      ),
      PieChartSectionData(
        value: info.totalOther.toDouble(),
        color: AppColors.delete,
        radius: 30,
        showTitle: false,
      ),
    ];
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelSmall),
        Text('$count', style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
