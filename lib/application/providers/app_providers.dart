import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pickture/data/datasources/database/app_database.dart';
import 'package:pickture/data/datasources/device_storage_channel.dart';
import 'package:pickture/data/datasources/drift_cleaning_session_datasource.dart';
import 'package:pickture/data/datasources/notification_service.dart';
import 'package:pickture/data/datasources/drift_trash_datasource.dart';
import 'package:pickture/data/datasources/local_photo_datasource.dart';
import 'package:pickture/data/repositories/cleaning_session_repository_impl.dart';
import 'package:pickture/data/repositories/photo_repository_impl.dart';
import 'package:pickture/data/repositories/statistics_repository_impl.dart';
import 'package:pickture/data/repositories/trash_repository_impl.dart';
import 'package:pickture/domain/repositories/cleaning_session_repository.dart';
import 'package:pickture/domain/repositories/photo_repository.dart';
import 'package:pickture/domain/repositories/statistics_repository.dart';
import 'package:pickture/domain/repositories/trash_repository.dart';

part 'app_providers.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden');
}

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  throw UnimplementedError('notificationServiceProvider must be overridden');
}

@riverpod
DeviceStorageChannel deviceStorageChannel(DeviceStorageChannelRef ref) {
  return DeviceStorageChannel();
}

@riverpod
LocalPhotoDatasource localPhotoDatasource(LocalPhotoDatasourceRef ref) {
  final storageChannel = ref.watch(deviceStorageChannelProvider);
  return LocalPhotoDatasource(storageChannel: storageChannel);
}

@riverpod
PhotoRepository photoRepository(PhotoRepositoryRef ref) {
  final datasource = ref.watch(localPhotoDatasourceProvider);
  return PhotoRepositoryImpl(datasource: datasource);
}

@riverpod
DriftCleaningSessionDatasource driftCleaningSessionDatasource(
  DriftCleaningSessionDatasourceRef ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return DriftCleaningSessionDatasource(db: db);
}

@riverpod
CleaningSessionRepository cleaningSessionRepository(
  CleaningSessionRepositoryRef ref,
) {
  final datasource = ref.watch(driftCleaningSessionDatasourceProvider);
  return CleaningSessionRepositoryImpl(datasource: datasource);
}

@riverpod
DriftTrashDatasource driftTrashDatasource(DriftTrashDatasourceRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftTrashDatasource(db: db);
}

@riverpod
TrashRepository trashRepository(TrashRepositoryRef ref) {
  final datasource = ref.watch(driftTrashDatasourceProvider);
  return TrashRepositoryImpl(datasource: datasource);
}

@riverpod
StatisticsRepository statisticsRepository(StatisticsRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return StatisticsRepositoryImpl(db: db);
}
