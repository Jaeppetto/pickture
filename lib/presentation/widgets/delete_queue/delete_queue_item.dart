import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import 'package:pickture/core/constants/app_constants.dart';

class DeleteQueueItem extends StatelessWidget {
  const DeleteQueueItem({
    super.key,
    required this.photoId,
    required this.onRestore,
  });

  final String photoId;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AssetEntityImage(
            AssetEntity(id: photoId, typeInt: 1, width: 0, height: 0),
            isOriginal: false,
            thumbnailSize: const ThumbnailSize.square(200),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: theme.colorScheme.surface,
              child: const Icon(Icons.broken_image),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRestore,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.undo_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
