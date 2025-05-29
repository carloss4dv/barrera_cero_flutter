import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DistanceTrackingService {
  static const String _totalDistanceKey = 'total_distance_traveled';
  static const String _lastPositionLatKey = 'last_position_lat';
  static const String _lastPositionLngKey = 'last_position_lng';
  static const String _isTrackingKey = 'is_tracking_enabled';

  bool _isTracking = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastPosition;
  double _totalDistance = 0.0;

  // Stream controllers para notificar cambios
  final StreamController<double> _distanceController = StreamController<double>.broadcast();
  final StreamController<bool> _trackingStateController = StreamController<bool>.broadcast();

  // Callback para notificar cambios de distancia a otros servicios
  Function(double newDistance)? onDistanceUpdated;

  // Getters para los streams
  Stream<double> get distanceStream => _distanceController.stream;
  Stream<bool> get trackingStateStream => _trackingStateController.stream;

  // Getters para el estado actual
  bool get isTracking => _isTracking;
  double get totalDistance => _totalDistance;

  /// Inicializa el servicio cargando datos persistidos
  Future<void> initialize() async {
    print('=== DEBUG: DistanceTrackingService.initialize() ===');
    await _loadPersistedData();
    print('=== DEBUG: Distancia total cargada: $_totalDistance metros ===');
  }

  /// Inicia el tracking de distancia
  Future<bool> startTracking() async {
    print('=== DEBUG: DistanceTrackingService.startTracking() ===');
    
    if (_isTracking) {
      print('=== DEBUG: Ya se está haciendo tracking ===');
      return true;
    }

    // Verificar permisos
    if (!await _checkLocationPermissions()) {
      print('=== ERROR: No hay permisos de ubicación ===');
      return false;
    }

    try {
      // Obtener posición inicial
      _lastPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Configurar stream de posiciones
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Actualizar cada 5 metros
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(_onPositionUpdate);

      _isTracking = true;
      await _saveTrackingState(true);
      
      _trackingStateController.add(_isTracking);
      print('=== DEBUG: Tracking iniciado exitosamente ===');
      return true;
      
    } catch (e) {
      print('=== ERROR: Error iniciando tracking: $e ===');
      return false;
    }
  }

  /// Detiene el tracking de distancia
  Future<void> stopTracking() async {
    print('=== DEBUG: DistanceTrackingService.stopTracking() ===');
    
    if (!_isTracking) {
      print('=== DEBUG: El tracking ya estaba detenido ===');
      return;
    }

    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
    
    await _saveTrackingState(false);
    await _saveLastPosition();
    
    _trackingStateController.add(_isTracking);
    print('=== DEBUG: Tracking detenido ===');
  }

  /// Callback cuando se actualiza la posición
  void _onPositionUpdate(Position position) {
    if (_lastPosition != null) {
      final distance = _calculateDistance(_lastPosition!, position);
      
      // Solo contar si la distancia es razonable (evitar saltos GPS)
      if (distance > 0 && distance < 100) { // Máximo 100 metros por actualización
        _totalDistance += distance;
        _saveDistanceToPreferences(_totalDistance);
        _distanceController.add(_totalDistance);
        onDistanceUpdated?.call(_totalDistance);
        
        print('=== DEBUG: Nueva distancia: ${distance.toStringAsFixed(2)}m, Total: ${_totalDistance.toStringAsFixed(2)}m ===');
      }
    }
    
    _lastPosition = position;
  }

  /// Calcula la distancia entre dos posiciones usando la fórmula de Haversine
  double _calculateDistance(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }

  /// Verifica los permisos de ubicación
  Future<bool> _checkLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('=== ERROR: Servicios de ubicación deshabilitados ===');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('=== ERROR: Permisos de ubicación denegados ===');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('=== ERROR: Permisos de ubicación denegados permanentemente ===');
      return false;
    }

    return true;
  }

  /// Carga datos persistidos desde SharedPreferences
  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _totalDistance = prefs.getDouble(_totalDistanceKey) ?? 0.0;
      _isTracking = prefs.getBool(_isTrackingKey) ?? false;
      
      final lastLat = prefs.getDouble(_lastPositionLatKey);
      final lastLng = prefs.getDouble(_lastPositionLngKey);
      
      if (lastLat != null && lastLng != null) {
        _lastPosition = Position(
          latitude: lastLat,
          longitude: lastLng,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
      
      print('=== DEBUG: Datos cargados - Distancia: $_totalDistance, Tracking: $_isTracking ===');
      
    } catch (e) {
      print('=== ERROR: Error cargando datos persistidos: $e ===');
    }
  }

  /// Guarda la distancia total en SharedPreferences
  Future<void> _saveDistanceToPreferences(double distance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_totalDistanceKey, distance);
    } catch (e) {
      print('=== ERROR: Error guardando distancia: $e ===');
    }
  }

  /// Guarda el estado de tracking
  Future<void> _saveTrackingState(bool isTracking) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isTrackingKey, isTracking);
    } catch (e) {
      print('=== ERROR: Error guardando estado de tracking: $e ===');
    }
  }

  /// Guarda la última posición
  Future<void> _saveLastPosition() async {
    if (_lastPosition == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_lastPositionLatKey, _lastPosition!.latitude);
      await prefs.setDouble(_lastPositionLngKey, _lastPosition!.longitude);
    } catch (e) {
      print('=== ERROR: Error guardando última posición: $e ===');
    }
  }

  /// Resetea la distancia total (para testing/debug)
  Future<void> resetDistance() async {
    print('=== DEBUG: Reseteando distancia total ===');
    _totalDistance = 0.0;
    await _saveDistanceToPreferences(_totalDistance);
    _distanceController.add(_totalDistance);
  }
  /// Simula distancia adicional en kilómetros (para testing/debug)
  Future<void> addTestKm(double km) async {
    final meters = km * 1000; // Convertir km a metros
    print('=== DEBUG: Agregando distancia de prueba: $km km ($meters metros) ===');
    _totalDistance += meters;
    await _saveDistanceToPreferences(_totalDistance);
    _distanceController.add(_totalDistance);
    
    // Notificar a otros servicios sobre el cambio de distancia
    onDistanceUpdated?.call(_totalDistance);
    
    print('=== DEBUG: Distancia total después de agregar: ${_totalDistance.toStringAsFixed(2)}m ===');
  }

  /// Obtiene la distancia en kilómetros
  double get totalDistanceInKm => _totalDistance / 1000.0;

  /// Limpia todos los datos (para logout)
  Future<void> clearAllData() async {
    print('=== DEBUG: Limpiando todos los datos de distancia ===');
    
    await stopTracking();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_totalDistanceKey);
      await prefs.remove(_lastPositionLatKey);
      await prefs.remove(_lastPositionLngKey);
      await prefs.remove(_isTrackingKey);
      
      _totalDistance = 0.0;
      _lastPosition = null;
      _isTracking = false;
      
      _distanceController.add(_totalDistance);
      _trackingStateController.add(_isTracking);
      
      print('=== DEBUG: Datos de distancia limpiados ===');
    } catch (e) {
      print('=== ERROR: Error limpiando datos: $e ===');
    }
  }

  /// Cierra los streams al destruir el servicio
  void dispose() {
    _positionStreamSubscription?.cancel();
    _distanceController.close();
    _trackingStateController.close();
  }
}