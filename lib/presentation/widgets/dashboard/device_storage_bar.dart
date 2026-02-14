import 'package:flutter/material.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/utils/storage_formatter.dart';
import 'package:pickture/domain/entities/storage_info.dart';
import 'package:pickture/l10n/app_localizations.dart';

class DeviceStorageBar extends StatelessWidget {
  const DeviceStorageBar({super.key, required this.info});

  final StorageInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (info.deviceTotal == 0) return const SizedBox.shrink();

    final usedRatio = (info.deviceTotal - info.deviceFree) / info.deviceTotal;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deviceStorage, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppConstants.spacing12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              child: LinearProgressIndicator(
                value: usedRatio.clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.1,
                ),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.freeSpace}: '
                  '${StorageFormatter.formatBytes(info.deviceFree)}',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  StorageFormatter.formatBytes(info.deviceTotal),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
