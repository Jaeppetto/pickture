import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/l10n/app_localizations.dart';
import 'package:pickture/presentation/providers/haptic_provider.dart';
import 'package:pickture/presentation/providers/reminder_provider.dart';
import 'package:pickture/presentation/widgets/settings/settings_section.dart';
import 'package:pickture/presentation/widgets/settings/settings_tile.dart';
import 'package:pickture/presentation/widgets/settings/statistics_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final reminderEnabled = ref.watch(reminderNotifierProvider);
    final hapticEnabled = ref.watch(hapticNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          const SizedBox(height: AppConstants.spacing8),

          const StatisticsCard(),

          SettingsSection(
            title: l10n.settingsGeneral,
            children: [
              SettingsTile.navigation(
                icon: Icons.delete_outline,
                title: l10n.trashTitle,
                subtitle: l10n.trashDescription,
                onTap: () => context.push('/trash'),
              ),
              const Divider(height: 1),
              SettingsTile.toggle(
                icon: Icons.notifications_outlined,
                title: l10n.reminderTitle,
                subtitle: l10n.reminderDescription,
                value: reminderEnabled,
                onChanged: (_) => ref
                    .read(reminderNotifierProvider.notifier)
                    .toggle(
                      title: l10n.reminderNotificationTitle,
                      body: l10n.reminderNotificationBody,
                    ),
              ),
              const Divider(height: 1),
              SettingsTile.toggle(
                icon: Icons.vibration,
                title: l10n.hapticTitle,
                subtitle: l10n.hapticDescription,
                value: hapticEnabled,
                onChanged: (_) =>
                    ref.read(hapticNotifierProvider.notifier).toggle(),
              ),
            ],
          ),

          SettingsSection(
            title: l10n.settingsAbout,
            children: [
              SettingsTile(
                icon: Icons.info_outline,
                title: l10n.settingsVersion,
                trailing: Text(
                  '1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Divider(height: 1),
              SettingsTile.navigation(
                icon: Icons.description_outlined,
                title: l10n.settingsLicenses,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: '1.0.0',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacing48),
        ],
      ),
    );
  }
}
