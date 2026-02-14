import 'package:pickture/domain/entities/cleaning_filter.dart';
import 'package:pickture/domain/entities/insight_card.dart';
import 'package:pickture/domain/entities/photo.dart';
import 'package:pickture/domain/entities/storage_info.dart';

enum PhotoPermissionStatus { authorized, limited, denied, notDetermined }

abstract class PhotoRepository {
  Future<PhotoPermissionStatus> requestPermission();
  Future<PhotoPermissionStatus> getPermissionStatus();
  Future<List<Photo>> getPhotos({int page = 0, int pageSize = 50});
  Future<int> getTotalCount();
  Future<StorageInfo> getStorageInfo();
  Future<List<InsightCard>> getInsights();
  Future<List<Photo>> getFilteredPhotos(
    CleaningFilter filter, {
    int page = 0,
    int pageSize = 50,
  });
  Future<int> getFilteredCount(CleaningFilter filter);
  Future<bool> deletePhotos(List<String> photoIds);
}
