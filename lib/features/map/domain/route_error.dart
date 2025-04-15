/// Errores que pueden ocurrir al obtener una ruta
class RouteError implements Exception {
  final RouteErrorType type;
  final String? message;

  RouteError(this.type, [this.message]);

  @override
  String toString() {
    return message ?? type.toString();
  }
}

/// Tipos de errores que pueden ocurrir al obtener una ruta
enum RouteErrorType {
  /// Error al obtener la ruta del servicio
  routeServiceError,
  
  /// No se pudo obtener la ubicación actual
  currentLocationError,
  
  /// No hay ruta accesible disponible
  noAccessibleRoute,
  
  /// Error desconocido
  unknown,
} 