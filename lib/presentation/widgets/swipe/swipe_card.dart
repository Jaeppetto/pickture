import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import 'package:pickture/domain/entities/photo.dart';

class SwipeCard extends StatelessWidget {
  const SwipeCard({super.key, required this.photo});

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AssetEntityImage(
        AssetEntity(
          id: photo.id,
          typeInt: photo.type == PhotoType.video ? 2 : 1,
          width: photo.width,
          height: photo.height,
        ),
        isOriginal: false,
        thumbnailSize: const ThumbnailSize.square(800),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: Theme.of(context).colorScheme.surface,
          child: const Icon(Icons.broken_image, size: 64),
        ),
      ),
    );
  }
}
