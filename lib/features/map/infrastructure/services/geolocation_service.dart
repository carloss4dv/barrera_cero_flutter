import 'package:geolocator/geolocator.dart';
import 'package:result_type/result_type.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/marker_model.dart';
import '../../domain/i_marker_service.dart';

/// Servicio para manejar la geolocalización del dispositivo
class GeolocationService {
  
  /// Verifica si los servicios de ubicación están habilitados
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Verifica y solicita permisos de ubicación
  Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission;
  }

  /// Obtiene la ubicación actual del dispositivo
  Future<Result<LatLng, MarkerError>> getCurrentDeviceLocation() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Failure(const MarkerError.locationServiceDisabled(
          'Los servicios de ubicación están desactivados. Por favor, actívalos en la configuración del dispositivo.'
        ));
      }

      // Verificar y solicitar permisos
      LocationPermission permission = await checkAndRequestPermission();
      
      if (permission == LocationPermission.denied) {
        return Failure(const MarkerError.locationPermissionDenied(
          'Se denegaron los permisos de ubicación. Por favor, concede los permisos en la configuración de la aplicación.'
        ));
      }
      
      if (permission == LocationPermission.deniedForever) {
        return Failure(const MarkerError.locationPermissionDenied(
          'Los permisos de ubicación están denegados permanentemente. Por favor, habilítalos en la configuración del dispositivo.'
        ));
      }

      // Obtener la posición actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return Success(LatLng(position.latitude, position.longitude));

    } catch (e) {
      String errorMessage = 'Error al obtener la ubicación: $e';
      
      if (e is LocationServiceDisabledException) {
        return Failure(const MarkerError.locationServiceDisabled(
          'Los servicios de ubicación están desactivados'
        ));
      } else if (e is PermissionDeniedException) {
        return Failure(const MarkerError.locationPermissionDenied(
          'Permisos de ubicación denegados'
        ));
      } else {
        return Failure(MarkerError.serverError(errorMessage));
      }
    }
  }

  /// Obtiene la ubicación actual como MarkerModel
  Future<Result<MarkerModel, MarkerError>> getCurrentLocationAsMarker() async {
    final locationResult = await getCurrentDeviceLocation();
    
    if (locationResult.isFailure) {
      return Failure(locationResult.failure);
    }

    final location = locationResult.success;
    final marker = MarkerModel.currentLocation(
      id: 'current_location',
      position: location,
    );

    return Success(marker);
  }

  /// Obtiene actualizaciones de ubicación en tiempo real
  Stream<LatLng> getLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Actualizar cada 10 metros
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((Position position) => LatLng(position.latitude, position.longitude));
  }
}
