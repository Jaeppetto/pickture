import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/theme/app_colors.dart';
import 'package:pickture/domain/entities/storage_info.dart';
import 'package:pickture/l10n/app_localizations.dart';

class StorageDonutChart extends StatefulWidget {
  const StorageDonutChart({super.key, required this.info});

  final StorageInfo info;

  @override
  State<StorageDonutChart> createState() => _StorageDonutChartState();
}

class _StorageDonutChartState extends State<StorageDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final total =
        widget.info.totalPhotos +
        widget.info.totalVideos +
        widget.info.totalScreenshots +
        widget.info.totalOther;

    if (total == 0) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: _buildSections(total, _animation.value),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Legend(
                  color: theme.colorScheme.primary,
                  label: l10n.photos,
                  count: widget.info.totalPhotos,
                ),
                _Legend(
                  color: AppColors.favorite,
                  label: l10n.videos,
                  count: widget.info.totalVideos,
                ),
                _Legend(
                  color: AppColors.keep,
                  label: l10n.screenshots,
                  count: widget.info.totalScreenshots,
                ),
                _Legend(
                  color: AppColors.delete,
                  label: l10n.other,
                  count: widget.info.totalOther,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(int total, double progress) {
    final radius = 30.0 * progress;
    return [
      PieChartSectionData(
        value: widget.info.totalPhotos.toDouble() * progress,
        color: AppColors.lightPrimary,
        radius: radius,
        showTitle: false,
      ),
      PieChartSectionData(
        value: widget.info.totalVideos.toDouble() * progress,
        color: AppColors.favorite,
        radius: radius,
        showTitle: false,
      ),
      PieChartSectionData(
        value: widget.info.totalScreenshots.toDouble() * progress,
        color: AppColors.keep,
        radius: radius,
        showTitle: false,
      ),
      PieChartSectionData(
        value: widget.info.totalOther.toDouble() * progress,
        color: AppColors.delete,
        radius: radius,
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
