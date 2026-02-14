import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pickture/application/providers/app_providers.dart';
import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/core/theme/app_colors.dart';
import 'package:pickture/core/utils/storage_formatter.dart';
import 'package:pickture/domain/entities/cleaning_decision.dart';
import 'package:pickture/l10n/app_localizations.dart';

class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: FutureBuilder(
        future: _loadSummary(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacing24),
              child: Column(
                children: [
                  const SizedBox(height: AppConstants.spacing48),
                  Icon(
                    Icons.celebration_rounded,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppConstants.spacing24),
                  Text(
                    l10n.sessionSummaryTitle,
                    style: theme.textTheme.displayLarge,
                  ),
                  const SizedBox(height: AppConstants.spacing48),
                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: l10n.totalReviewed,
                          value: '${summary.reviewed}',
                          icon: Icons.visibility,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing8),
                      Expanded(
                        child: _StatCard(
                          label: l10n.totalDeleted,
                          value: '${summary.deleted}',
                          icon: Icons.delete_rounded,
                          color: AppColors.delete,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: l10n.totalKept,
                          value: '${summary.kept}',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.keep,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing8),
                      Expanded(
                        child: _StatCard(
                          label: l10n.totalFavorited,
                          value: '${summary.favorited}',
                          icon: Icons.star_rounded,
                          color: AppColors.favorite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacing32),
                  // Storage freed
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacing24),
                      child: Column(
                        children: [
                          Text(
                            l10n.storageFreed,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppConstants.spacing8),
                          Text(
                            StorageFormatter.formatBytes(summary.freedBytes),
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing32),
                  if (summary.deleted > 0)
                    FilledButton.icon(
                      onPressed: () => context.push('/delete-queue/$sessionId'),
                      icon: const Icon(Icons.delete_sweep_rounded),
                      label: Text(l10n.viewDeleteQueue),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                    ),
                  const SizedBox(height: AppConstants.spacing12),
                  OutlinedButton(
                    onPressed: () => context.go('/home'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: Text(l10n.done),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<_SessionSummary> _loadSummary(WidgetRef ref) async {
    final repo = ref.read(cleaningSessionRepositoryProvider);
    final decisions = await repo.getDecisions(sessionId);

    int deleted = 0, kept = 0, favorited = 0;
    for (final d in decisions) {
      switch (d.type) {
        case CleaningDecisionType.delete:
          deleted++;
        case CleaningDecisionType.keep:
          kept++;
        case CleaningDecisionType.favorite:
          favorited++;
      }
    }

    return _SessionSummary(
      reviewed: decisions.length,
      deleted: deleted,
      kept: kept,
      favorited: favorited,
      freedBytes: deleted * 3 * 1024 * 1024, // estimate
    );
  }
}

class _SessionSummary {
  const _SessionSummary({
    required this.reviewed,
    required this.deleted,
    required this.kept,
    required this.favorited,
    required this.freedBytes,
  });

  final int reviewed;
  final int deleted;
  final int kept;
  final int favorited;
  final int freedBytes;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
