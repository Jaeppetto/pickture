import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo.freezed.dart';
part 'photo.g.dart';

enum PhotoType { image, video, screenshot, gif }

@freezed
abstract class Photo with _$Photo {
  const factory Photo({
    required String id,
    required String path,
    required DateTime createdAt,
    required int fileSize,
    required int width,
    required int height,
    required PhotoType type,
    Duration? duration,
  }) = _Photo;

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
}
