import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/utils/storage_formatter.dart';
import 'package:pickture/domain/entities/photo.dart';
import 'package:pickture/l10n/app_localizations.dart';

class PhotoDetailOverlay extends StatelessWidget {
  const PhotoDetailOverlay({
    super.key,
    required this.photo,
    required this.onClose,
  });

  final Photo photo;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd();

    return GestureDetector(
      onTap: onClose,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                icon: Icons.calendar_today,
                label: l10n.photoDate,
                value: dateFormat.format(photo.createdAt),
              ),
              const SizedBox(height: AppConstants.spacing8),
              _DetailRow(
                icon: Icons.sd_storage,
                label: l10n.photoSize,
                value: photo.fileSize > 0
                    ? StorageFormatter.formatBytes(photo.fileSize)
                    : '-',
              ),
              const SizedBox(height: AppConstants.spacing8),
              _DetailRow(
                icon: Icons.aspect_ratio,
                label: l10n.photoDimensions,
                value: '${photo.width} x ${photo.height}',
              ),
              const SizedBox(height: AppConstants.spacing32),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: AppConstants.spacing8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
