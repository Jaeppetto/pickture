import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/l10n/app_localizations.dart';
import 'package:pickture/presentation/providers/delete_queue_provider.dart';
import 'package:pickture/presentation/widgets/delete_queue/confirm_delete_button.dart';
import 'package:pickture/presentation/widgets/delete_queue/delete_queue_item.dart';

class DeleteQueueScreen extends ConsumerWidget {
  const DeleteQueueScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(deleteQueueProvider(sessionId));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deleteQueueTitle)),
      body: queueAsync.when(
        data: (decisions) {
          if (decisions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppConstants.spacing16),
                  Text(
                    l10n.noPhotosToClean,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Text(
                  l10n.totalToDelete(decisions.length),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing16,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppConstants.spacing4,
                    mainAxisSpacing: AppConstants.spacing4,
                  ),
                  itemCount: decisions.length,
                  itemBuilder: (context, index) {
                    final decision = decisions[index];
                    return DeleteQueueItem(
                      photoId: decision.photoId,
                      onRestore: () {
                        ref
                            .read(deleteQueueProvider(sessionId).notifier)
                            .restorePhoto(decision.photoId);
                      },
                    );
                  },
                ),
              ),
              ConfirmDeleteButton(
                count: decisions.length,
                onConfirm: () async {
                  final success = await ref
                      .read(deleteQueueProvider(sessionId).notifier)
                      .confirmDeletion();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.deleteSuccess)));
                    context.go('/home');
                  }
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
