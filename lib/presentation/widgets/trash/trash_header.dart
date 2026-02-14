import 'package:flutter/material.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/utils/storage_formatter.dart';
import 'package:pickture/domain/entities/trash_item.dart';
import 'package:pickture/l10n/app_localizations.dart';

class TrashHeader extends StatelessWidget {
  const TrashHeader({super.key, required this.items});

  final List<TrashItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final totalSize = items.fold<int>(0, (sum, item) => sum + item.fileSize);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.trashItemCount(items.length),
                style: theme.textTheme.titleMedium,
              ),
              if (totalSize > 0) ...[
                const SizedBox(width: AppConstants.spacing8),
                Text('·', style: theme.textTheme.titleMedium),
                const SizedBox(width: AppConstants.spacing8),
                Text(
                  l10n.trashStorageUsed(
                    StorageFormatter.formatBytes(totalSize),
                  ),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            l10n.trashRetentionNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
