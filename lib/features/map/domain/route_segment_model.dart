import 'package:latlong2/latlong.dart';
import '../../accessibility/domain/accessibility_level.dart';

/// Modelo que representa un segmento de ruta con sus características de accesibilidad
class RouteSegment {
  final LatLng start;
  final LatLng end;
  final double distance; // en metros
  final bool hasStairs;
  final bool hasRamp;
  final double slope; // pendiente en porcentaje
  final String surfaceType; // tipo de superficie (asfalto, tierra, etc.)

  RouteSegment({
    required this.start,
    required this.end,
    required this.distance,
    this.hasStairs = false,
    this.hasRamp = false,
    this.slope = 0.0,
    this.surfaceType = 'asfalto',
  });

  /// Calcula la pendiente entre dos puntos
  static double calculateSlope(LatLng start, LatLng end, double distance) {
    // Aquí podríamos implementar un cálculo más preciso usando datos de elevación
    // Por ahora usamos una aproximación simple
    return 0.0; // TODO: Implementar cálculo real de pendiente
  }

  /// Verifica si el segmento es accesible según los criterios dados
  bool isAccessible({
    required bool avoidStairs,
    required bool preferRamps,
    double maxSlope = 8.0, // pendiente máxima permitida en porcentaje
  }) {
    if (avoidStairs && hasStairs) return false;
    if (preferRamps && !hasRamp) return false;
    if (slope > maxSlope) return false;
    
    return true;
  }

  /// Calcula el nivel de accesibilidad del segmento
  AccessibilityLevel getAccessibilityLevel({
    required bool avoidStairs,
    required bool preferRamps,
    double maxSlope = 8.0,
  }) {
    // Si no hay validaciones (hasStairs y hasRamp son false por defecto),
    // asumimos que es accesible
    if (!hasStairs && !hasRamp && slope == 0.0) {
      return AccessibilityLevel.good;
    }

    // Si tiene escaleras y debemos evitarlas, es malo
    if (avoidStairs && hasStairs) {
      return AccessibilityLevel.bad;
    }

    // Si no tiene rampa y preferimos rampas, es malo
    if (preferRamps && !hasRamp) {
      return AccessibilityLevel.bad;
    }

    // Si la pendiente es muy alta, es malo
    if (slope > maxSlope) {
      return AccessibilityLevel.bad;
    }

    // Si tiene rampa y la pendiente es moderada, es medio
    if (hasRamp && slope > maxSlope * 0.5) {
      return AccessibilityLevel.medium;
    }

    // En cualquier otro caso, es bueno
    return AccessibilityLevel.good;
  }
} 