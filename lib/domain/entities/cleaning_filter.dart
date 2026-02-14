import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:pickture/domain/entities/photo.dart';

part 'cleaning_filter.freezed.dart';
part 'cleaning_filter.g.dart';

@freezed
abstract class CleaningFilter with _$CleaningFilter {
  const factory CleaningFilter({
    PhotoType? photoType,
    DateTime? startDate,
    DateTime? endDate,
    int? minFileSize,
  }) = _CleaningFilter;

  factory CleaningFilter.fromJson(Map<String, dynamic> json) =>
      _$CleaningFilterFromJson(json);
}
