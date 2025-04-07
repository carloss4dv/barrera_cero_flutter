import 'package:result_type/result_type.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/marker_model.dart';
import '../../domain/i_marker_service.dart';
import '../../domain/marker_metadata.dart';
import 'dart:math';

class MarkerService implements IMarkerService {
  // Lista de marcadores de prueba en Zaragoza
  final List<MarkerModel> _mockMarkers = [
    // Marker with no reports to test grey color functionality
    MarkerModel.pointOfInterest(
      id: 'marker_no_reports',
      position: LatLng(41.6480, -0.8830),
      title: 'Punto sin reportes',
      description: 'Este punto no tiene reportes de accesibilidad',
      metadata: MarkerMetadata(
        hasRamp: false,
        hasElevator: false,
        hasAccessibleBathroom: false,
        hasBrailleSignage: false,
        hasAudioGuidance: false,
        hasTactilePavement: false,
        additionalNotes: 'Sin reportes de accesibilidad',
        accessibilityScore: 0,
      ),
    ),
    MarkerModel.pointOfInterest(
      id: 'marker_plaza_pilar',
      position: LatLng(41.6560, -0.8773),
      title: 'Basílica del Pilar',
      description: 'Principal símbolo de Zaragoza y centro religioso',
      metadata: MarkerMetadata(
        hasRamp: true,
        hasElevator: true,
        hasAccessibleBathroom: true,
        hasBrailleSignage: true,
        hasAudioGuidance: true,
        hasTactilePavement: true,
        additionalNotes: 'Excelente accesibilidad en todo el recinto',
        accessibilityScore: 5,
      ),
    ),
    MarkerModel.pointOfInterest(
      id: 'marker_aljaferia',
      position: LatLng(41.6617, -0.8940),
      title: 'Palacio de la Aljafería',
      description: 'Palacio fortificado del siglo XI',
      metadata: MarkerMetadata(
        hasRamp: true,
        hasElevator: false,
        hasAccessibleBathroom: true,
        hasBrailleSignage: true,
        hasAudioGuidance: true,
        hasTactilePavement: false,
        additionalNotes: 'Algunas áreas históricas tienen acceso limitado',
        accessibilityScore: 3,
      ),
    ),
    MarkerModel.destination(
      id: 'marker_parque_grande',
      position: LatLng(41.6362, -0.8951),
      title: 'Parque Grande José Antonio Labordeta',
      description: 'Pulmón verde de la ciudad',
      metadata: MarkerMetadata(
        hasRamp: true,
        hasElevator: false,
        hasAccessibleBathroom: true,
        hasBrailleSignage: true,
        hasAudioGuidance: false,
        hasTactilePavement: true,
        additionalNotes: 'Senderos accesibles y áreas de descanso',
        accessibilityScore: 4,
      ),
    ),
    MarkerModel.pointOfInterest(
      id: 'marker_mercado_central',
      position: LatLng(41.6541, -0.8780),
      title: 'Mercado Central',
      description: 'Mercado histórico de productos frescos',
      metadata: MarkerMetadata(
        hasRamp: true,
        hasElevator: true,
        hasAccessibleBathroom: true,
        hasBrailleSignage: false,
        hasAudioGuidance: false,
        hasTactilePavement: true,
        additionalNotes: 'Acceso adaptado a todos los puestos',
        accessibilityScore: 4,
      ),
    ),
    MarkerModel.pointOfInterest(
      id: 'marker_puente_piedra',
      position: LatLng(41.6575, -0.8780),
      title: 'Puente de Piedra',
      description: 'Puente histórico sobre el río Ebro',
      metadata: MarkerMetadata(
        hasRamp: true,
        hasElevator: false,
        hasAccessibleBathroom: false,
        hasBrailleSignage: true,
        hasAudioGuidance: false,
        hasTactilePavement: true,
        additionalNotes: 'Rampas en ambos extremos del puente',
        accessibilityScore: 3,
      ),
    ),
    MarkerModel.destination(
      id: 'marker_estacion_delicias',
      position: LatLng(41.6592, -0.9117),
      title: 'Estación Delicias',
      description: 'Estación de tren y autobuses',
      metadata: MarkerMetadata(
        hasRamp: true,
        hasElevator: true,
        hasAccessibleBathroom: true,
        hasBrailleSignage: true,
        hasAudioGuidance: true,
        hasTactilePavement: true,
        additionalNotes: 'Estación completamente adaptada',
        accessibilityScore: 5,
      ),
    ),
    MarkerModel.pointOfInterest(
      id: 'marker_el_tubo',
      position: LatLng(41.6519, -0.8792),
      title: 'El Tubo',
      description: 'Zona de tapas tradicional',
      metadata: MarkerMetadata(
        hasRamp: false,
        hasElevator: false,
        hasAccessibleBathroom: false,
        hasBrailleSignage: false,
        hasAudioGuidance: false,
        hasTactilePavement: false,
        additionalNotes: 'Zona histórica con accesibilidad limitada',
        accessibilityScore: 1,
      ),
    ),
    MarkerModel.destination(
      id: 'marker_grancasa',
      position: LatLng(41.6710, -0.8940),
      title: 'Centro Comercial GranCasa',
      description: 'Centro comercial con tiendas y restaurantes',
      metadata: MarkerMetadata(
        hasRamp: true,
        hasElevator: true,
        hasAccessibleBathroom: true,
        hasBrailleSignage: true,
        hasAudioGuidance: true,
        hasTactilePavement: true,
        additionalNotes: 'Centro comercial completamente accesible',
        accessibilityScore: 5,
      ),
    ),
    MarkerModel.pointOfInterest(
      id: 'marker_universidad',
      position: LatLng(41.6435, -0.8960),
      title: 'Ciudad Universitaria',
      description: 'Campus principal de la Universidad de Zaragoza',
      metadata: MarkerMetadata(
        hasRamp: true,
        hasElevator: true,
        hasAccessibleBathroom: true,
        hasBrailleSignage: true,
        hasAudioGuidance: false,
        hasTactilePavement: true,
        additionalNotes: 'Campus adaptado para personas con movilidad reducida',
        accessibilityScore: 4,
      ),
    ),
    // Mantener los marcadores originales con nuevos IDs para compatibilidad
    MarkerModel.pointOfInterest(
      id: 'marker_plaza_mayor',
      position: LatLng(41.6515, -0.8761),
      title: 'Catedral de San Salvador (La Seo)',
      description: 'Catedral histórica con estilos arquitectónicos diversos',
      metadata: MarkerMetadata(
        hasRamp: true,
        hasElevator: false,
        hasAccessibleBathroom: true,
        hasBrailleSignage: true,
        hasAudioGuidance: true,
        hasTactilePavement: false,
        additionalNotes: 'Acceso adaptado a la planta principal',
        accessibilityScore: 3,
      ),
    ),
    MarkerModel.destination(
      id: 'marker_calle_principal',
      position: LatLng(41.6505, -0.8790),
      title: 'Calle Alfonso I',
      description: 'Calle comercial peatonal en el centro',
      metadata: MarkerMetadata(
        hasRamp: true,
        hasElevator: false,
        hasAccessibleBathroom: false,
        hasBrailleSignage: true,
        hasAudioGuidance: false,
        hasTactilePavement: true,
        additionalNotes: 'Calle peatonal con pavimento accesible',
        accessibilityScore: 4,
      ),
    ),
    MarkerModel.pointOfInterest(
      id: 'marker_callejon',
      position: LatLng(41.6525, -0.8810),
      title: 'Callejón del Arco',
      description: 'Callejón estrecho del casco histórico',
      metadata: MarkerMetadata(
        hasRamp: false,
        hasElevator: false,
        hasAccessibleBathroom: false,
        hasBrailleSignage: false,
        hasAudioGuidance: false,
        hasTactilePavement: false,
        additionalNotes: 'Zona histórica con accesibilidad limitada',
        accessibilityScore: 1,
      ),
    ),
    MarkerModel.destination(
      id: '5',
      position: LatLng(41.6683, -0.8934),
      title: 'Acuario de Zaragoza',
      description: 'El acuario fluvial más grande de Europa',
      metadata: MarkerMetadata(
        hasRamp: true,
        hasElevator: true,
        hasAccessibleBathroom: true,
        hasBrailleSignage: true,
        hasAudioGuidance: true,
        hasTactilePavement: true,
        additionalNotes: 'Recorrido completamente adaptado',
        accessibilityScore: 5,
      ),
    ),
  ];

  // Ubicación actual simulada en Zaragoza (Plaza del Pilar)
  final MarkerModel _currentLocation = MarkerModel.currentLocation(
    id: 'current_location',
    position: LatLng(41.6560, -0.8773), // Plaza del Pilar
  );

  @override
  Future<Result<List<MarkerModel>, MarkerError>> getNearbyMarkers({
    required double latitude,
    required double longitude,
    double radiusInMeters = 1000,
  }) async {
    try {
      // Simulamos un pequeño retraso de red
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Filtrar marcadores por distancia
      final LatLng center = LatLng(latitude, longitude);
      final Distance distance = Distance();
      
      final nearbyMarkers = _mockMarkers.where((marker) {
        final double distanceInMeters = distance.as(
          LengthUnit.Meter,
          center, 
          marker.position
        );
        return distanceInMeters <= radiusInMeters;
      }).toList();
      
      return Success(nearbyMarkers);
    } catch (e) {
      return Failure(const MarkerError.serverError());
    }
  }

  @override
  Future<Result<MarkerModel, MarkerError>> getCurrentLocation() async {
    try {
      // Simulamos un pequeño retraso
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Simulamos una ubicación actual aleatoria cercana a Zaragoza
      final Random random = Random();
      final double latVariation = (random.nextDouble() - 0.5) * 0.01;
      final double lngVariation = (random.nextDouble() - 0.5) * 0.01;
      
      final newLocation = MarkerModel.currentLocation(
        id: 'current_location',
        position: LatLng(
          _currentLocation.position.latitude + latVariation,
          _currentLocation.position.longitude + lngVariation,
        ),
      );
      
      return Success(newLocation);
    } catch (e) {
      return Failure(const MarkerError.locationServiceDisabled());
    }
  }

  @override
  Future<Result<MarkerModel, MarkerError>> getMarkerById(String id) async {
    try {
      // Simulamos un pequeño retraso
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Buscar el marcador por ID
      final marker = _mockMarkers.firstWhere(
        (marker) => marker.id == id,
        orElse: () => throw Exception('Marker not found'),
      );
      
      return Success(marker);
    } catch (e) {
      return Failure(const MarkerError.notFound());
    }
  }
} 