import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/l10n/app_localizations.dart';
import 'package:pickture/presentation/providers/trash_provider.dart';
import 'package:pickture/presentation/widgets/trash/trash_header.dart';
import 'package:pickture/presentation/widgets/trash/trash_item_tile.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final trashAsync = ref.watch(trashNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trashTitle),
        actions: [
          trashAsync.maybeWhen(
            data: (items) => items.isNotEmpty
                ? TextButton(
                    onPressed: () =>
                        _confirmEmptyTrash(context, ref, l10n, items.length),
                    child: Text(l10n.trashEmptyAll),
                  )
                : const SizedBox.shrink(),
            orElse: SizedBox.shrink,
          ),
        ],
      ),
      body: trashAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  Text(
                    l10n.trashEmpty,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              TrashHeader(items: items),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppConstants.spacing8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: AppConstants.spacing4,
                    crossAxisSpacing: AppConstants.spacing4,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return TrashItemTile(
                      item: item,
                      onRestore: () {
                        ref
                            .read(trashNotifierProvider.notifier)
                            .restore(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.trashRestoreSuccess)),
                        );
                      },
                      onDelete: () {
                        ref
                            .read(trashNotifierProvider.notifier)
                            .permanentlyDelete(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.trashDeleteSuccess)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _confirmEmptyTrash(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    int count,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.trashEmptyAll),
        content: Text(l10n.trashEmptyConfirm(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.done),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(trashNotifierProvider.notifier).emptyTrash();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.trashPermanentDelete),
          ),
        ],
      ),
    );
  }
}
