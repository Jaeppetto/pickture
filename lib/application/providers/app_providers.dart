import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pickture/data/datasources/local_cleaning_session_datasource.dart';
import 'package:pickture/data/datasources/local_photo_datasource.dart';
import 'package:pickture/data/repositories/cleaning_session_repository_impl.dart';
import 'package:pickture/data/repositories/photo_repository_impl.dart';
import 'package:pickture/domain/repositories/cleaning_session_repository.dart';
import 'package:pickture/domain/repositories/photo_repository.dart';

part 'app_providers.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
}

@riverpod
LocalPhotoDatasource localPhotoDatasource(LocalPhotoDatasourceRef ref) {
  return LocalPhotoDatasource();
}

@riverpod
PhotoRepository photoRepository(PhotoRepositoryRef ref) {
  final datasource = ref.watch(localPhotoDatasourceProvider);
  return PhotoRepositoryImpl(datasource: datasource);
}

@riverpod
LocalCleaningSessionDatasource localCleaningSessionDatasource(
  LocalCleaningSessionDatasourceRef ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalCleaningSessionDatasource(prefs: prefs);
}

@riverpod
CleaningSessionRepository cleaningSessionRepository(
  CleaningSessionRepositoryRef ref,
) {
  final datasource = ref.watch(localCleaningSessionDatasourceProvider);
  return CleaningSessionRepositoryImpl(datasource: datasource);
}
