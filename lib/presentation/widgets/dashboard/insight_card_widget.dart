import 'package:flutter/material.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/utils/storage_formatter.dart';
import 'package:pickture/domain/entities/insight_card.dart';
import 'package:pickture/l10n/app_localizations.dart';

class InsightCardWidget extends StatelessWidget {
  const InsightCardWidget({super.key, required this.insight, this.onTap});

  final InsightCard insight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing4,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _iconColor(insight.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                ),
                child: Icon(
                  _icon(insight.type),
                  color: _iconColor(insight.type),
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(l10n, insight),
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      StorageFormatter.formatBytes(insight.totalBytes),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(AppLocalizations l10n, InsightCard insight) {
    switch (insight.type) {
      case InsightType.screenshots:
        return l10n.insightScreenshots(insight.count);
      case InsightType.oldPhotos:
        return l10n.insightOldPhotos(insight.count);
      case InsightType.largeFiles:
        return l10n.insightLargeFiles(insight.count);
    }
  }

  IconData _icon(InsightType type) {
    switch (type) {
      case InsightType.screenshots:
        return Icons.screenshot;
      case InsightType.oldPhotos:
        return Icons.history;
      case InsightType.largeFiles:
        return Icons.sd_storage;
    }
  }

  Color _iconColor(InsightType type) {
    switch (type) {
      case InsightType.screenshots:
        return Colors.orange;
      case InsightType.oldPhotos:
        return Colors.blue;
      case InsightType.largeFiles:
        return Colors.red;
    }
  }
}
