import 'package:result_type/result_type.dart';
import 'marker_model.dart';

/// Errores posibles al interactuar con el servicio de marcadores
class MarkerError implements Exception {
  final String message;
  final MarkerErrorType type;

  const MarkerError._(this.type, [this.message = '']);

  const MarkerError.notFound([String message = ''])
      : this._(MarkerErrorType.notFound, message);
  const MarkerError.serverError([String message = ''])
      : this._(MarkerErrorType.serverError, message);
  const MarkerError.locationPermissionDenied([String message = ''])
      : this._(MarkerErrorType.locationPermissionDenied, message);
  const MarkerError.locationServiceDisabled([String message = ''])
      : this._(MarkerErrorType.locationServiceDisabled, message);

  @override
  String toString() => 'MarkerError: $type${message.isNotEmpty ? " - $message" : ""}';
}

enum MarkerErrorType {
  notFound,
  serverError,
  locationPermissionDenied,
  locationServiceDisabled
}

/// Interfaz que define las operaciones disponibles para el servicio de marcadores
abstract class IMarkerService {
  /// Obtiene todos los puntos de interés cercanos a una ubicación
  /// 
  /// [latitude] y [longitude] representan el centro desde donde buscar
  /// [radiusInMeters] es la distancia máxima para buscar marcadores
  /// 
  /// Retorna [Result.failure] con:
  /// - [MarkerError.serverError] si hay un error al obtener los datos
  /// - [MarkerError.locationPermissionDenied] si no hay permisos de ubicación
  Future<Result<List<MarkerModel>, MarkerError>> getNearbyMarkers({
    required double latitude,
    required double longitude,
    double radiusInMeters = 1000,
  });

  /// Obtiene la ubicación actual del usuario
  /// 
  /// Retorna [Result.failure] con:
  /// - [MarkerError.locationPermissionDenied] si no hay permisos de ubicación
  /// - [MarkerError.locationServiceDisabled] si el servicio de ubicación está desactivado
  Future<Result<MarkerModel, MarkerError>> getCurrentLocation();

  /// Obtiene un marcador específico por su ID
  /// 
  /// Retorna [Result.failure] con:
  /// - [MarkerError.notFound] si el marcador no existe
  /// - [MarkerError.serverError] si hay un error al obtener los datos
  Future<Result<MarkerModel, MarkerError>> getMarkerById(String id);
} 