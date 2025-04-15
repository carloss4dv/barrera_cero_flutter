import 'package:latlong2/latlong.dart';

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
} 