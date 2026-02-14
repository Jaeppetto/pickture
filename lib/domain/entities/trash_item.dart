import 'package:freezed_annotation/freezed_annotation.dart';

part 'trash_item.freezed.dart';
part 'trash_item.g.dart';

@freezed
abstract class TrashItem with _$TrashItem {
  const factory TrashItem({
    required int id,
    required String photoId,
    String? sessionId,
    @Default(0) int fileSize,
    required DateTime trashedAt,
    required DateTime expiresAt,
  }) = _TrashItem;

  factory TrashItem.fromJson(Map<String, dynamic> json) =>
      _$TrashItemFromJson(json);
}
