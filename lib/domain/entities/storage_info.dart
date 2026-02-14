import 'package:freezed_annotation/freezed_annotation.dart';

part 'storage_info.freezed.dart';
part 'storage_info.g.dart';

@freezed
abstract class StorageInfo with _$StorageInfo {
  const factory StorageInfo({
    required int totalPhotos,
    required int totalVideos,
    required int totalScreenshots,
    required int totalOther,
    required int photoBytes,
    required int videoBytes,
    required int screenshotBytes,
    required int otherBytes,
    required int deviceTotal,
    required int deviceFree,
  }) = _StorageInfo;

  factory StorageInfo.fromJson(Map<String, dynamic> json) =>
      _$StorageInfoFromJson(json);
}
