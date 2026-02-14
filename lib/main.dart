import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pickture/app.dart';
import 'package:pickture/application/providers/app_providers.dart';
import 'package:pickture/data/datasources/database/database_provider.dart';
import 'package:pickture/data/datasources/database/migration_helper.dart';
import 'package:pickture/data/datasources/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final db = createAppDatabase();

  // One-time migration from SharedPreferences to drift
  final migrationHelper = MigrationHelper(db: db, prefs: prefs);
  await migrationHelper.migrateIfNeeded();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const PicktureApp(),
    ),
  );
}
