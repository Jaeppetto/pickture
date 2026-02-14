import 'package:freezed_annotation/freezed_annotation.dart';

part 'insight_card.freezed.dart';
part 'insight_card.g.dart';

enum InsightType { screenshots, oldPhotos, largeFiles }

@freezed
abstract class InsightCard with _$InsightCard {
  const factory InsightCard({
    required InsightType type,
    required int count,
    required int totalBytes,
  }) = _InsightCard;

  factory InsightCard.fromJson(Map<String, dynamic> json) =>
      _$InsightCardFromJson(json);
}
