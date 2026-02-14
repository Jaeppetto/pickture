import 'package:flutter/material.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/utils/storage_formatter.dart';
import 'package:pickture/domain/entities/storage_info.dart';
import 'package:pickture/l10n/app_localizations.dart';

class DeviceStorageBar extends StatefulWidget {
  const DeviceStorageBar({super.key, required this.info});

  final StorageInfo info;

  @override
  State<DeviceStorageBar> createState() => _DeviceStorageBarState();
}

class _DeviceStorageBarState extends State<DeviceStorageBar>
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

    if (widget.info.deviceTotal == 0) {
      return const SizedBox.shrink();
    }

    final usedRatio =
        (widget.info.deviceTotal - widget.info.deviceFree) /
        widget.info.deviceTotal;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deviceStorage, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppConstants.spacing12),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  child: LinearProgressIndicator(
                    value: usedRatio.clamp(0.0, 1.0) * _animation.value,
                    minHeight: 12,
                    backgroundColor: theme.colorScheme.onSurface.withValues(
                      alpha: 0.1,
                    ),
                    color: theme.colorScheme.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: AppConstants.spacing8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.freeSpace}: '
                  '${StorageFormatter.formatBytes(widget.info.deviceFree)}',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  StorageFormatter.formatBytes(widget.info.deviceTotal),
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
