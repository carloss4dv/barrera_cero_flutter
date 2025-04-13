import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/i_marker_service.dart';
import '../../domain/marker_model.dart';
import '../../domain/marker_metadata.dart';
import 'combined_marker_service.dart';

class MockDataUploader {
  final IMarkerService _markerService;

  MockDataUploader({IMarkerService? markerService})
      : _markerService = markerService ?? GetIt.instance<IMarkerService>();

  Future<void> uploadMockData() async {
    print('\n=== Iniciando subida de datos mock a Firestore ===');
    
    // Lista de marcadores de prueba
    final mockMarkers = [
      // Marker with no reports to test grey color functionality
      {
        'id': 'marker_no_reports',
        'position': {'latitude': 41.6480, 'longitude': -0.8830},
        'title': 'Punto sin reportes',
        'description': 'Este punto no tiene reportes de accesibilidad',
        'type': 'pointOfInterest',
        'metadata': {
          'hasRamp': false,
          'hasElevator': false,
          'hasAccessibleBathroom': false,
          'hasBrailleSignage': false,
          'hasAudioGuidance': false,
          'hasTactilePavement': false,
          'additionalNotes': 'Sin reportes de accesibilidad',
          'accessibilityScore': 0,
        },
      },
      {
        'id': 'marker_plaza_pilar',
        'position': {'latitude': 41.6560, 'longitude': -0.8773},
        'title': 'Basílica del Pilar',
        'description': 'Principal símbolo de Zaragoza y centro religioso',
        'type': 'pointOfInterest',
        'metadata': {
          'hasRamp': true,
          'hasElevator': true,
          'hasAccessibleBathroom': true,
          'hasBrailleSignage': true,
          'hasAudioGuidance': true,
          'hasTactilePavement': true,
          'additionalNotes': 'Excelente accesibilidad en todo el recinto',
          'accessibilityScore': 5,
        },
      },
      {
        'id': 'marker_aljaferia',
        'position': {'latitude': 41.6617, 'longitude': -0.8940},
        'title': 'Palacio de la Aljafería',
        'description': 'Palacio fortificado del siglo XI',
        'type': 'pointOfInterest',
        'metadata': {
          'hasRamp': true,
          'hasElevator': false,
          'hasAccessibleBathroom': true,
          'hasBrailleSignage': true,
          'hasAudioGuidance': true,
          'hasTactilePavement': false,
          'additionalNotes': 'Algunas áreas históricas tienen acceso limitado',
          'accessibilityScore': 3,
        },
      },
      {
        'id': 'marker_parque_grande',
        'position': {'latitude': 41.6362, 'longitude': -0.8951},
        'title': 'Parque Grande José Antonio Labordeta',
        'description': 'Pulmón verde de la ciudad',
        'type': 'destination',
        'metadata': {
          'hasRamp': true,
          'hasElevator': false,
          'hasAccessibleBathroom': true,
          'hasBrailleSignage': true,
          'hasAudioGuidance': false,
          'hasTactilePavement': true,
          'additionalNotes': 'Senderos accesibles y áreas de descanso',
          'accessibilityScore': 4,
        },
      },
      {
        'id': 'marker_mercado_central',
        'position': {'latitude': 41.6541, 'longitude': -0.8780},
        'title': 'Mercado Central',
        'description': 'Mercado histórico de productos frescos',
        'type': 'pointOfInterest',
        'metadata': {
          'hasRamp': true,
          'hasElevator': true,
          'hasAccessibleBathroom': true,
          'hasBrailleSignage': false,
          'hasAudioGuidance': false,
          'hasTactilePavement': true,
          'additionalNotes': 'Acceso adaptado a todos los puestos',
          'accessibilityScore': 4,
        },
      },
      {
        'id': 'marker_puente_piedra',
        'position': {'latitude': 41.6575, 'longitude': -0.8780},
        'title': 'Puente de Piedra',
        'description': 'Puente histórico sobre el río Ebro',
        'type': 'pointOfInterest',
        'metadata': {
          'hasRamp': true,
          'hasElevator': false,
          'hasAccessibleBathroom': false,
          'hasBrailleSignage': true,
          'hasAudioGuidance': false,
          'hasTactilePavement': true,
          'additionalNotes': 'Rampas en ambos extremos del puente',
          'accessibilityScore': 3,
        },
      },
      {
        'id': 'marker_estacion_delicias',
        'position': {'latitude': 41.6592, 'longitude': -0.9117},
        'title': 'Estación Delicias',
        'description': 'Estación de tren y autobuses',
        'type': 'destination',
        'metadata': {
          'hasRamp': true,
          'hasElevator': true,
          'hasAccessibleBathroom': true,
          'hasBrailleSignage': true,
          'hasAudioGuidance': true,
          'hasTactilePavement': true,
          'additionalNotes': 'Estación completamente adaptada',
          'accessibilityScore': 5,
        },
      },
      {
        'id': 'marker_el_tubo',
        'position': {'latitude': 41.6519, 'longitude': -0.8792},
        'title': 'El Tubo',
        'description': 'Zona de tapas tradicional',
        'type': 'pointOfInterest',
        'metadata': {
          'hasRamp': false,
          'hasElevator': false,
          'hasAccessibleBathroom': false,
          'hasBrailleSignage': false,
          'hasAudioGuidance': false,
          'hasTactilePavement': false,
          'additionalNotes': 'Zona histórica con accesibilidad limitada',
          'accessibilityScore': 1,
        },
      },
      {
        'id': 'marker_grancasa',
        'position': {'latitude': 41.6710, 'longitude': -0.8940},
        'title': 'Centro Comercial GranCasa',
        'description': 'Centro comercial con tiendas y restaurantes',
        'type': 'destination',
        'metadata': {
          'hasRamp': true,
          'hasElevator': true,
          'hasAccessibleBathroom': true,
          'hasBrailleSignage': true,
          'hasAudioGuidance': true,
          'hasTactilePavement': true,
          'additionalNotes': 'Centro comercial completamente accesible',
          'accessibilityScore': 5,
        },
      },
      {
        'id': 'marker_universidad',
        'position': {'latitude': 41.6435, 'longitude': -0.8960},
        'title': 'Ciudad Universitaria',
        'description': 'Campus principal de la Universidad de Zaragoza',
        'type': 'pointOfInterest',
        'metadata': {
          'hasRamp': true,
          'hasElevator': true,
          'hasAccessibleBathroom': true,
          'hasBrailleSignage': true,
          'hasAudioGuidance': false,
          'hasTactilePavement': true,
          'additionalNotes': 'Campus adaptado para personas con movilidad reducida',
          'accessibilityScore': 4,
        },
      },
      {
        'id': 'marker_plaza_mayor',
        'position': {'latitude': 41.6515, 'longitude': -0.8761},
        'title': 'Catedral de San Salvador (La Seo)',
        'description': 'Catedral histórica con estilos arquitectónicos diversos',
        'type': 'pointOfInterest',
        'metadata': {
          'hasRamp': true,
          'hasElevator': false,
          'hasAccessibleBathroom': true,
          'hasBrailleSignage': true,
          'hasAudioGuidance': true,
          'hasTactilePavement': false,
          'additionalNotes': 'Acceso adaptado a la planta principal',
          'accessibilityScore': 3,
        },
      },
      {
        'id': 'marker_calle_principal',
        'position': {'latitude': 41.6505, 'longitude': -0.8790},
        'title': 'Calle Alfonso I',
        'description': 'Calle comercial peatonal en el centro',
        'type': 'destination',
        'metadata': {
          'hasRamp': true,
          'hasElevator': false,
          'hasAccessibleBathroom': false,
          'hasBrailleSignage': true,
          'hasAudioGuidance': false,
          'hasTactilePavement': true,
          'additionalNotes': 'Calle peatonal con pavimento accesible',
          'accessibilityScore': 4,
        },
      },
      {
        'id': 'marker_callejon',
        'position': {'latitude': 41.6525, 'longitude': -0.8810},
        'title': 'Callejón del Arco',
        'description': 'Callejón estrecho del casco histórico',
        'type': 'pointOfInterest',
        'metadata': {
          'hasRamp': false,
          'hasElevator': false,
          'hasAccessibleBathroom': false,
          'hasBrailleSignage': false,
          'hasAudioGuidance': false,
          'hasTactilePavement': false,
          'additionalNotes': 'Zona histórica con accesibilidad limitada',
          'accessibilityScore': 1,
        },
      },
      {
        'id': 'marker_acuario',
        'position': {'latitude': 41.6683, 'longitude': -0.8934},
        'title': 'Acuario de Zaragoza',
        'description': 'El acuario fluvial más grande de Europa',
        'type': 'destination',
        'metadata': {
          'hasRamp': true,
          'hasElevator': true,
          'hasAccessibleBathroom': true,
          'hasBrailleSignage': true,
          'hasAudioGuidance': true,
          'hasTactilePavement': true,
          'additionalNotes': 'Recorrido completamente adaptado',
          'accessibilityScore': 5,
        },
      },
    ];

    // Subir cada marcador a Firestore
    for (var markerData in mockMarkers) {
      try {
        print('\nSubiendo marcador: ${markerData['title']}');
        
        final result = await _markerService.savePlace(
          MarkerModel(
            id: markerData['id'] as String,
            position: LatLng(
              (markerData['position'] as Map<String, dynamic>)['latitude'] as double,
              (markerData['position'] as Map<String, dynamic>)['longitude'] as double,
            ),
            type: MarkerType.values.firstWhere(
              (e) => e.toString() == 'MarkerType.${markerData['type']}',
              orElse: () => MarkerType.pointOfInterest,
            ),
            title: markerData['title'] as String,
            description: markerData['description'] as String,
            metadata: MarkerMetadata.fromJson(markerData['metadata'] as Map<String, dynamic>),
          ),
        );

        if (result.isSuccess) {
          print('✅ Marcador subido exitosamente');
        } else {
          print('❌ Error al subir marcador: ${result.failure}');
        }
      } catch (e) {
        print('❌ Error al procesar marcador: $e');
      }
    }

    print('\n=== Proceso de subida completado ===');
  }
} 