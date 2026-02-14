import 'package:photo_manager/photo_manager.dart';

import 'package:pickture/core/constants/app_constants.dart';
import 'package:pickture/data/models/photo_model.dart';
import 'package:pickture/domain/entities/cleaning_filter.dart';
import 'package:pickture/domain/entities/insight_card.dart';
import 'package:pickture/domain/entities/photo.dart';
import 'package:pickture/domain/entities/storage_info.dart';
import 'package:pickture/domain/repositories/photo_repository.dart';

class LocalPhotoDatasource {
  Future<PhotoPermissionStatus> requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    return _mapPermission(result);
  }

  Future<PhotoPermissionStatus> getPermissionStatus() async {
    final result = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    return _mapPermission(result);
  }

  Future<List<Photo>> getPhotos({
    required int page,
    required int pageSize,
  }) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
    );
    if (albums.isEmpty) return [];

    final recentAlbum = albums.first;
    final assets = await recentAlbum.getAssetListPaged(
      page: page,
      size: pageSize,
    );

    return assets.map((e) => e.toPhoto()).toList();
  }

  Future<int> getTotalCount() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
    );
    if (albums.isEmpty) return 0;
    return await albums.first.assetCountAsync;
  }

  Future<StorageInfo> getStorageInfo() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
    );
    if (albums.isEmpty) {
      return const StorageInfo(
        totalPhotos: 0,
        totalVideos: 0,
        totalScreenshots: 0,
        totalOther: 0,
        photoBytes: 0,
        videoBytes: 0,
        screenshotBytes: 0,
        otherBytes: 0,
        deviceTotal: 0,
        deviceFree: 0,
      );
    }

    final recentAlbum = albums.first;
    final totalCount = await recentAlbum.assetCountAsync;

    int photos = 0, videos = 0, screenshots = 0, other = 0;
    int photoBytes = 0, videoBytes = 0, screenshotBytes = 0, otherBytes = 0;

    const batchSize = 100;
    for (int page = 0; page * batchSize < totalCount; page++) {
      final assets = await recentAlbum.getAssetListPaged(
        page: page,
        size: batchSize,
      );
      for (final asset in assets) {
        final size = asset.size;
        final estimatedBytes = size.width.toInt() * size.height.toInt() * 3;
        switch (asset.type) {
          case AssetType.video:
            videos++;
            videoBytes += estimatedBytes;
          case AssetType.image:
            photos++;
            photoBytes += estimatedBytes;
          default:
            other++;
            otherBytes += estimatedBytes;
        }
      }
    }

    // Try to detect screenshots from album names
    for (final album in albums) {
      final name = album.name.toLowerCase();
      if (name.contains('screenshot') || name.contains('스크린샷')) {
        final count = await album.assetCountAsync;
        screenshots += count;
        // Adjust photos count
        photos = (photos - count).clamp(0, photos);
      }
    }

    // Device storage info (placeholder values for MVP)
    const deviceTotal = 256 * 1024 * 1024 * 1024;
    const deviceFree = 128 * 1024 * 1024 * 1024;

    return StorageInfo(
      totalPhotos: photos,
      totalVideos: videos,
      totalScreenshots: screenshots,
      totalOther: other,
      photoBytes: photoBytes,
      videoBytes: videoBytes,
      screenshotBytes: screenshotBytes,
      otherBytes: otherBytes,
      deviceTotal: deviceTotal,
      deviceFree: deviceFree,
    );
  }

  Future<List<InsightCard>> getInsights() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
    );
    if (albums.isEmpty) return [];

    final insights = <InsightCard>[];
    final recentAlbum = albums.first;
    final totalCount = await recentAlbum.assetCountAsync;

    int screenshotCount = 0;
    int oldPhotoCount = 0;
    int largeFileCount = 0;
    const screenshotBytes = 0;
    int oldPhotoBytes = 0;
    int largeFileBytes = 0;

    final cutoffDate = DateTime.now().subtract(
      const Duration(days: AppConstants.oldPhotoMonths * 30),
    );

    const batchSize = 100;
    for (var page = 0; page * batchSize < totalCount; page++) {
      final assets = await recentAlbum.getAssetListPaged(
        page: page,
        size: batchSize,
      );
      for (final asset in assets) {
        final estimatedBytes = asset.width * asset.height * 3;

        if (asset.createDateTime.isBefore(cutoffDate)) {
          oldPhotoCount++;
          oldPhotoBytes += estimatedBytes;
        }

        if (estimatedBytes > AppConstants.largeSizeThreshold) {
          largeFileCount++;
          largeFileBytes += estimatedBytes;
        }
      }
    }

    // Screenshot count from albums
    for (final album in albums) {
      final name = album.name.toLowerCase();
      if (name.contains('screenshot') || name.contains('스크린샷')) {
        screenshotCount += await album.assetCountAsync;
      }
    }

    if (screenshotCount > 0) {
      insights.add(
        InsightCard(
          type: InsightType.screenshots,
          count: screenshotCount,
          totalBytes: screenshotBytes,
        ),
      );
    }
    if (oldPhotoCount > 0) {
      insights.add(
        InsightCard(
          type: InsightType.oldPhotos,
          count: oldPhotoCount,
          totalBytes: oldPhotoBytes,
        ),
      );
    }
    if (largeFileCount > 0) {
      insights.add(
        InsightCard(
          type: InsightType.largeFiles,
          count: largeFileCount,
          totalBytes: largeFileBytes,
        ),
      );
    }

    return insights;
  }

  Future<List<Photo>> getFilteredPhotos(
    CleaningFilter filter, {
    required int page,
    required int pageSize,
  }) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
    );
    if (albums.isEmpty) return [];

    final recentAlbum = albums.first;
    // Load more to account for filtering
    final loadSize = pageSize * 3;
    final allAssets = await recentAlbum.getAssetListPaged(
      page: page,
      size: loadSize,
    );

    final filtered = allAssets
        .where((asset) {
          if (filter.photoType != null) {
            final mapped = AssetEntityToPhoto._mapType(asset.type);
            if (mapped != filter.photoType) return false;
          }
          if (filter.startDate != null &&
              asset.createDateTime.isBefore(filter.startDate!)) {
            return false;
          }
          if (filter.endDate != null &&
              asset.createDateTime.isAfter(filter.endDate!)) {
            return false;
          }
          return true;
        })
        .take(pageSize);

    return filtered.map((e) => e.toPhoto()).toList();
  }

  Future<int> getFilteredCount(CleaningFilter filter) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
    );
    if (albums.isEmpty) return 0;

    final recentAlbum = albums.first;
    final totalCount = await recentAlbum.assetCountAsync;
    if (filter.photoType == null &&
        filter.startDate == null &&
        filter.endDate == null &&
        filter.minFileSize == null) {
      return totalCount;
    }

    int count = 0;
    const batchSize = 100;
    for (int page = 0; page * batchSize < totalCount; page++) {
      final assets = await recentAlbum.getAssetListPaged(
        page: page,
        size: batchSize,
      );
      for (final asset in assets) {
        var matches = true;
        if (filter.photoType != null) {
          final mapped = AssetEntityToPhoto._mapType(asset.type);
          if (mapped != filter.photoType) matches = false;
        }
        if (filter.startDate != null &&
            asset.createDateTime.isBefore(filter.startDate!)) {
          matches = false;
        }
        if (filter.endDate != null &&
            asset.createDateTime.isAfter(filter.endDate!)) {
          matches = false;
        }
        if (matches) count++;
      }
    }

    return count;
  }

  Future<bool> deletePhotos(List<String> photoIds) async {
    final result = await PhotoManager.editor.deleteWithIds(photoIds);
    return result.isNotEmpty;
  }

  PhotoPermissionStatus _mapPermission(PermissionState state) {
    if (state.isAuth) return PhotoPermissionStatus.authorized;
    if (state == PermissionState.limited) {
      return PhotoPermissionStatus.limited;
    }
    if (state == PermissionState.denied) {
      return PhotoPermissionStatus.denied;
    }
    return PhotoPermissionStatus.notDetermined;
  }
}
