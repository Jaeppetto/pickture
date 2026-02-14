import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/domain/repositories/photo_repository.dart';
import 'package:pickture/l10n/app_localizations.dart';
import 'package:pickture/presentation/providers/insights_provider.dart';
import 'package:pickture/presentation/providers/photo_permission_provider.dart';
import 'package:pickture/presentation/providers/storage_analysis_provider.dart';
import 'package:pickture/presentation/widgets/dashboard/cleaning_prediction_card.dart';
import 'package:pickture/presentation/widgets/dashboard/device_storage_bar.dart';
import 'package:pickture/presentation/widgets/dashboard/insight_card_widget.dart';
import 'package:pickture/presentation/widgets/dashboard/storage_donut_chart.dart';
import 'package:pickture/presentation/widgets/dashboard/storage_header_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionAsync = ref.watch(photoPermissionProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardTitle)),
      body: permissionAsync.when(
        data: (status) {
          if (status == PhotoPermissionStatus.authorized ||
              status == PhotoPermissionStatus.limited) {
            return _buildDashboard(context, ref, l10n, theme);
          }
          return _buildPermissionRequest(context, ref, status, theme, l10n);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final storageAsync = ref.watch(storageAnalysisProvider);
    final insightsAsync = ref.watch(insightsProvider);

    return storageAsync.when(
      data: (info) => SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: AppConstants.spacing16,
          bottom: AppConstants.spacing32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StorageHeaderCard(info: info),
            const SizedBox(height: AppConstants.spacing16),
            StorageDonutChart(info: info),
            const SizedBox(height: AppConstants.spacing16),
            DeviceStorageBar(info: info),
            const SizedBox(height: AppConstants.spacing16),
            CleaningPredictionCard(info: info),
            const SizedBox(height: AppConstants.spacing24),
            insightsAsync.when(
              data: (insights) => Column(
                children: insights
                    .map(
                      (insight) => InsightCardWidget(
                        insight: insight,
                        onTap: () => context.go('/clean'),
                      ),
                    )
                    .toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppConstants.spacing24),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing16,
              ),
              child: FilledButton.icon(
                onPressed: () => context.go('/clean'),
                icon: const Icon(Icons.auto_awesome),
                label: Text(l10n.startCleaning),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPermissionRequest(
    BuildContext context,
    WidgetRef ref,
    PhotoPermissionStatus status,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    if (status == PhotoPermissionStatus.denied) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_photography_outlined,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(l10n.permissionDenied, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              l10n.permissionDeniedDescription,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(l10n.organizeYourGallery, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l10n.allowAccessToStart, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ref.read(photoPermissionProvider.notifier).requestPermission();
            },
            child: Text(l10n.grantPhotoAccess),
          ),
        ],
      ),
    );
  }
}
