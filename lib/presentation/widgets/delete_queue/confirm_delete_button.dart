import 'package:flutter/material.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/theme/app_colors.dart';
import 'package:pickture/l10n/app_localizations.dart';

class ConfirmDeleteButton extends StatelessWidget {
  const ConfirmDeleteButton({
    super.key,
    required this.count,
    required this.onConfirm,
  });

  final int count;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: FilledButton(
        onPressed: () => _showConfirmDialog(context, l10n),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.delete,
          minimumSize: const Size.fromHeight(56),
        ),
        child: Text(l10n.confirmDelete),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteDialog(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.delete),
            child: Text(l10n.confirmDelete),
          ),
        ],
      ),
    );
  }
}
