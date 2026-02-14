import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pickture/application/providers/app_providers.dart';
import 'package:pickture/domain/repositories/photo_repository.dart';

part 'photo_permission_provider.g.dart';

@riverpod
class PhotoPermission extends _$PhotoPermission {
  @override
  FutureOr<PhotoPermissionStatus> build() {
    return PhotoPermissionStatus.notDetermined;
  }

  Future<void> requestPermission() async {
    state = const AsyncLoading();
    final repo = ref.read(photoRepositoryProvider);
    final status = await repo.requestPermission();
    state = AsyncData(status);
  }
}
