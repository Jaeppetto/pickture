import 'package:pickture/data/datasources/local_photo_datasource.dart';
import 'package:pickture/domain/entities/cleaning_filter.dart';
import 'package:pickture/domain/entities/insight_card.dart';
import 'package:pickture/domain/entities/photo.dart';
import 'package:pickture/domain/entities/storage_info.dart';
import 'package:pickture/domain/repositories/photo_repository.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  PhotoRepositoryImpl({required this.datasource});

  final LocalPhotoDatasource datasource;

  @override
  Future<PhotoPermissionStatus> requestPermission() {
    return datasource.requestPermission();
  }

  @override
  Future<PhotoPermissionStatus> getPermissionStatus() {
    return datasource.getPermissionStatus();
  }

  @override
  Future<List<Photo>> getPhotos({int page = 0, int pageSize = 50}) {
    return datasource.getPhotos(page: page, pageSize: pageSize);
  }

  @override
  Future<int> getTotalCount() {
    return datasource.getTotalCount();
  }

  @override
  Future<StorageInfo> getStorageInfo() {
    return datasource.getStorageInfo();
  }

  @override
  Future<List<InsightCard>> getInsights() {
    return datasource.getInsights();
  }

  @override
  Future<List<Photo>> getFilteredPhotos(
    CleaningFilter filter, {
    int page = 0,
    int pageSize = 50,
  }) {
    return datasource.getFilteredPhotos(filter, page: page, pageSize: pageSize);
  }

  @override
  Future<int> getFilteredCount(CleaningFilter filter) {
    return datasource.getFilteredCount(filter);
  }

  @override
  Future<bool> deletePhotos(List<String> photoIds) {
    return datasource.deletePhotos(photoIds);
  }
}
