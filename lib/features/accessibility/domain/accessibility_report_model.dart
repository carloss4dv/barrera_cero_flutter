import 'package:freezed_annotation/freezed_annotation.dart';

part 'accessibility_report_model.freezed.dart';

@freezed
abstract class AccessibilityReportModel with _$AccessibilityReportModel {
  const factory AccessibilityReportModel({
    required String id,
    required String userId,
    required String comments,
    required AccessibilityLevel level,
  }) = _AccessibilityReportModel;

  factory AccessibilityReportModel.empty() => const AccessibilityReportModel(
        id: '',
        userId: '',
        comments: '',
        level: AccessibilityLevel.medium,
      );
}

enum AccessibilityLevel {
  good,
  medium,
  bad
} 