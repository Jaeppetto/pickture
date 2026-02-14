import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pickture/application/providers/app_providers.dart';
import 'package:pickture/domain/entities/storage_info.dart';

part 'storage_analysis_provider.g.dart';

@riverpod
class StorageAnalysis extends _$StorageAnalysis {
  @override
  FutureOr<StorageInfo> build() async {
    final repo = ref.read(photoRepositoryProvider);
    return repo.getStorageInfo();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repo = ref.read(photoRepositoryProvider);
    state = AsyncData(await repo.getStorageInfo());
  }
}
