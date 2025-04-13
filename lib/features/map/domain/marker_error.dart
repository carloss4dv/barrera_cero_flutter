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