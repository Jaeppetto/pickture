import 'package:flutter/material.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/utils/storage_formatter.dart';
import 'package:pickture/domain/entities/storage_info.dart';
import 'package:pickture/l10n/app_localizations.dart';

class CleaningPredictionCard extends StatelessWidget {
  const CleaningPredictionCard({super.key, required this.info});

  final StorageInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Estimate: screenshots + 20% of old photos
    final estimatedFreeable =
        info.screenshotBytes + (info.photoBytes * 0.2).toInt();

    if (estimatedFreeable == 0) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: Text(
                l10n.cleaningPrediction(
                  StorageFormatter.formatBytes(estimatedFreeable),
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
