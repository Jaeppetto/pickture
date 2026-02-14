import 'package:photo_manager/photo_manager.dart';

import 'package:pickture/domain/entities/photo.dart';

extension AssetEntityToPhoto on AssetEntity {
  Photo toPhoto() {
    return Photo(
      id: id,
      path: id,
      createdAt: createDateTime,
      fileSize: 0,
      width: width,
      height: height,
      type: mapType(type),
      duration: type == AssetType.video ? Duration(seconds: duration) : null,
    );
  }

  Future<Photo> toPhotoWithSize() async {
    final file = await originFile;
    final size = file != null ? await file.length() : 0;
    return Photo(
      id: id,
      path: id,
      createdAt: createDateTime,
      fileSize: size,
      width: width,
      height: height,
      type: mapType(type),
      duration: type == AssetType.video ? Duration(seconds: duration) : null,
    );
  }

  static PhotoType mapType(AssetType type) {
    switch (type) {
      case AssetType.image:
        return PhotoType.image;
      case AssetType.video:
        return PhotoType.video;
      case AssetType.audio:
        return PhotoType.image;
      case AssetType.other:
        return PhotoType.image;
    }
  }
}
