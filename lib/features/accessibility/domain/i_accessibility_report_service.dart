import 'package:result_dart/result_dart.dart';
import 'accessibility_report_model.dart';

class AccessibilityReportException implements Exception {
  final String message;
  AccessibilityReportException(this.message);
  
  @override
  String toString() => message;
}

abstract class IAccessibilityReportService {
  /// Obtiene todos los reportes de accesibilidad para un marcador específico
  Future<ResultDart<List<AccessibilityReportModel>, AccessibilityReportException>> getReportsForMarker(String markerId);
  
  /// Añade un nuevo reporte de accesibilidad para un marcador
  Future<ResultDart<AccessibilityReportModel, AccessibilityReportException>> addReport(String markerId, AccessibilityReportModel report);
  
  /// Calcula el nivel de accesibilidad predominante para un marcador basado en sus reportes
  Future<ResultDart<AccessibilityLevel, AccessibilityReportException>> getAccessibilityLevelForMarker(String markerId);
  
  /// Obtiene el conteo de reportes por nivel para un marcador
  Future<ResultDart<Map<AccessibilityLevel, int>, AccessibilityReportException>> getReportCountByLevel(String markerId);
} 