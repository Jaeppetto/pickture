import 'package:flutter/material.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/utils/storage_formatter.dart';
import 'package:pickture/domain/entities/storage_info.dart';
import 'package:pickture/l10n/app_localizations.dart';

class StorageHeaderCard extends StatelessWidget {
  const StorageHeaderCard({super.key, required this.info});

  final StorageInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final totalItems =
        info.totalPhotos + info.totalVideos + info.totalScreenshots;
    final totalBytes =
        info.photoBytes +
        info.videoBytes +
        info.screenshotBytes +
        info.otherBytes;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppConstants.spacing12),
            Text(
              l10n.totalPhotosVideos(totalItems),
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              '${l10n.totalStorage}: '
              '${StorageFormatter.formatBytes(totalBytes)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
