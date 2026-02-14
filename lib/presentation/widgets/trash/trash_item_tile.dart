import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/domain/entities/trash_item.dart' as domain;
import 'package:pickture/l10n/app_localizations.dart';

class TrashItemTile extends StatelessWidget {
  const TrashItemTile({
    super.key,
    required this.item,
    required this.onRestore,
    required this.onDelete,
  });

  final domain.TrashItem item;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final daysLeft = item.expiresAt.difference(DateTime.now()).inDays;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AssetEntityImage(
            AssetEntity(
              id: item.photoId,
              typeInt: 1,
              width: AppConstants.thumbnailSize,
              height: AppConstants.thumbnailSize,
            ),
            isOriginal: false,
            thumbnailSize: const ThumbnailSize.square(
              AppConstants.thumbnailSize,
            ),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.broken_image,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Positioned(
            top: AppConstants.spacing4,
            right: AppConstants.spacing4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing4,
                vertical: AppConstants.spacing2,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Text(
                l10n.trashDaysRemaining(daysLeft.clamp(0, 30)),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onLongPress: () => _showActions(context, l10n)),
            ),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text(l10n.restore),
              onTap: () {
                Navigator.pop(context);
                onRestore();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_forever,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.trashPermanentDelete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
