import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/accessibility_report_model.dart';

part 'accessibility_report_dto.freezed.dart';
part 'accessibility_report_dto.g.dart';

@freezed
class AccessibilityReportDto with _$AccessibilityReportDto {
  const factory AccessibilityReportDto({
    @Default('') String id,
    @JsonKey(name: 'user_id')
    @Default('') String userId,
    @Default('') String comments,
    @JsonKey(name: 'accessibility_level')
    @Default(AccessibilityLevel.medium) AccessibilityLevel level,
  }) = _AccessibilityReportDto;

  factory AccessibilityReportDto.fromJson(Map<String, dynamic> json) =>
      _$AccessibilityReportDtoFromJson(json);

  factory AccessibilityReportDto.fromDomain(AccessibilityReportModel model) => AccessibilityReportDto(
        id: model.id,
        userId: model.userId,
        comments: model.comments,
        level: model.level,
      );
}

extension AccessibilityReportDtoX on AccessibilityReportDto {
  AccessibilityReportModel toDomain() => AccessibilityReportModel(
        id: id,
        userId: userId,
        comments: comments,
        level: level,
      );
} 