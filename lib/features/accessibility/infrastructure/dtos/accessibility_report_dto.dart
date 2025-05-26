import '../../domain/accessibility_report_model.dart';

class AccessibilityReportDto {
  final String id;
  final String userId;
  final String userName;
  final String comments;
  final AccessibilityLevel level;

  const AccessibilityReportDto({
    this.id = '',
    required this.userId,
    required this.userName,
    required this.comments,
    required this.level,
  });
  factory AccessibilityReportDto.fromJson(Map<String, dynamic> json) {
    return AccessibilityReportDto(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      comments: json['comments'] as String? ?? '',
      level: _stringToAccessibilityLevel(json['accessibility_level'] as String? ?? 'medium'),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'comments': comments,
      'accessibility_level': _accessibilityLevelToString(level),
    };
  }
  // Método para convertir desde el modelo de dominio
  factory AccessibilityReportDto.fromDomain(AccessibilityReportModel model) {
    return AccessibilityReportDto(
      id: model.id,
      userId: model.userId,
      userName: model.userName,
      comments: model.comments,
      level: model.level,
    );
  }
  // Método para convertir al modelo de dominio
  AccessibilityReportModel toDomain() {
    return AccessibilityReportModel(
      id: id,
      userId: userId,
      userName: userName,
      comments: comments,
      level: level,
    );
  }

  static AccessibilityLevel _stringToAccessibilityLevel(String levelString) {
    switch (levelString.toLowerCase()) {
      case 'good':
        return AccessibilityLevel.good;
      case 'bad':
        return AccessibilityLevel.bad;
      case 'medium':
      default:
        return AccessibilityLevel.medium;
    }
  }

  static String _accessibilityLevelToString(AccessibilityLevel level) {
    switch (level) {
      case AccessibilityLevel.good:
        return 'good';
      case AccessibilityLevel.medium:
        return 'medium';
      case AccessibilityLevel.bad:
        return 'bad';
    }
  }
}