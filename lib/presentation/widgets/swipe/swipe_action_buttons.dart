import 'package:flutter/material.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/theme/app_colors.dart';
import 'package:pickture/l10n/app_localizations.dart';

class SwipeActionButtons extends StatelessWidget {
  const SwipeActionButtons({
    super.key,
    required this.onDelete,
    required this.onKeep,
    required this.onFavorite,
    required this.onUndo,
    required this.canUndo,
  });

  final VoidCallback onDelete;
  final VoidCallback onKeep;
  final VoidCallback onFavorite;
  final VoidCallback onUndo;
  final bool canUndo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing16,
        vertical: AppConstants.spacing8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Undo
          _ActionButton(
            icon: Icons.undo_rounded,
            label: l10n.undo,
            color: Colors.grey,
            size: 44,
            onTap: canUndo ? onUndo : null,
          ),
          // Delete
          _ActionButton(
            icon: Icons.close_rounded,
            label: l10n.deleteAction,
            color: AppColors.delete,
            size: 60,
            onTap: onDelete,
          ),
          // Keep
          _ActionButton(
            icon: Icons.check_rounded,
            label: l10n.keepAction,
            color: AppColors.keep,
            size: 60,
            onTap: onKeep,
          ),
          // Favorite
          _ActionButton(
            icon: Icons.star_rounded,
            label: l10n.favoriteAction,
            color: AppColors.favorite,
            size: 44,
            onTap: onFavorite,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final effectiveColor = isDisabled ? color.withValues(alpha: 0.3) : color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: effectiveColor, width: 2),
            ),
            child: Icon(icon, color: effectiveColor, size: size * 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: effectiveColor)),
      ],
    );
  }
}
