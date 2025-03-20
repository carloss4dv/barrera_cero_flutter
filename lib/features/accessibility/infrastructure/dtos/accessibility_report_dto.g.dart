// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accessibility_report_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccessibilityReportDto _$AccessibilityReportDtoFromJson(
  Map<String, dynamic> json,
) => _AccessibilityReportDto(
  id: json['id'] as String? ?? '',
  userId: json['user_id'] as String? ?? '',
  comments: json['comments'] as String? ?? '',
  level:
      $enumDecodeNullable(
        _$AccessibilityLevelEnumMap,
        json['accessibility_level'],
      ) ??
      AccessibilityLevel.medium,
);

Map<String, dynamic> _$AccessibilityReportDtoToJson(
  _AccessibilityReportDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'comments': instance.comments,
  'accessibility_level': _$AccessibilityLevelEnumMap[instance.level]!,
};

const _$AccessibilityLevelEnumMap = {
  AccessibilityLevel.good: 'good',
  AccessibilityLevel.medium: 'medium',
  AccessibilityLevel.bad: 'bad',
};
