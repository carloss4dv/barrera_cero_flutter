import 'package:result_type/result_type.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/i_marker_service.dart';
import '../../domain/marker_model.dart';
import 'marker_service.dart';
import 'firestore_marker_service.dart';

class CombinedMarkerService implements IMarkerService {
  final MarkerService _mockService;
  final FirestoreMarkerService _firestoreService;

  CombinedMarkerService({
    MarkerService? mockService,
    FirestoreMarkerService? firestoreService,
  })  : _mockService = mockService ?? MarkerService(),
        _firestoreService = firestoreService ?? FirestoreMarkerService();

  @override
  Future<Result<List<MarkerModel>, MarkerError>> getNearbyMarkers({
    required double latitude,
    required double longitude,
    double radiusInMeters = 1000,
  }) async {
    try {
      print('\n=== Iniciando getNearbyMarkers ===');
      print('Ubicación: lat=$latitude, lon=$longitude, radio=$radiusInMeters metros');

      // Obtener marcadores de ambas fuentes
      print('\nObteniendo marcadores del mockup...');
      final mockResult = await _mockService.getNearbyMarkers(
        latitude: latitude,
        longitude: longitude,
        radiusInMeters: radiusInMeters,
      );
      print('Marcadores del mockup: ${mockResult.isSuccess ? mockResult.success.length : 'Error'}');
      if (mockResult.isFailure) {
        print('Error en mockup: ${mockResult.failure}');
      }

      print('\nObteniendo marcadores de Firestore...');
      try {
        // final firestoreResult = await _firestoreService.getNearbyMarkers(
        //   latitude: latitude,
        //   longitude: longitude,
        //   radiusInMeters: radiusInMeters,
        // );
        final firestoreResult = await _firestoreService.getAllPlaces();
        print('Marcadores de Firestore: ${firestoreResult.isSuccess ? firestoreResult.success.length : 'Error'}');
        if (firestoreResult.isFailure) {
          print('Error en Firestore: ${firestoreResult.failure}');
        }

        // Combinar resultados si ambos son exitosos
        if (mockResult.isSuccess && firestoreResult.isSuccess) {
          final combinedMarkers = [
            ...mockResult.success,
            ...firestoreResult.success,
          ];
          
          print('\nTotal de marcadores combinados: ${combinedMarkers.length}');
          
          // Eliminar duplicados basados en ID si existieran
          final uniqueMarkers = combinedMarkers.fold<Map<String, MarkerModel>>(
            {},
            (map, marker) {
              map[marker.id] = marker;
              return map;
            },
          ).values.toList();

          print('Marcadores únicos después de eliminar duplicados: ${uniqueMarkers.length}');
          print('\nDetalles de los marcadores:');
          for (var marker in uniqueMarkers) {
            print('- ID: ${marker.id}, Tipo: ${marker.type}, Título: ${marker.title}, Posición: ${marker.position.latitude}, ${marker.position.longitude}');
          }

          return Success(uniqueMarkers);
        }

        // Si Firestore falla pero mock funciona, devolver solo mock
        if (mockResult.isSuccess) {
          print('\nUsando solo marcadores del mockup debido a error en Firestore');
          return mockResult;
        }

        // Si mock falla pero Firestore funciona, devolver solo Firestore
        if (firestoreResult.isSuccess) {
          print('\nUsando solo marcadores de Firestore debido a error en el mockup');
          return firestoreResult;
        }
      } catch (e) {
        print('\nError al obtener marcadores de Firestore: $e');
        print('Stack trace: ${e.toString()}');
      }

      // Si ambos fallan, devolver error
      print('\nError al obtener marcadores de ambas fuentes');
      return Failure(const MarkerError.serverError('Error al obtener marcadores de ambas fuentes'));
    } catch (e) {
      print('\nError inesperado en getNearbyMarkers: $e');
      print('Stack trace: ${e.toString()}');
      return Failure(MarkerError.serverError(e.toString()));
    }
  }

  @override
  Future<Result<MarkerModel, MarkerError>> getMarkerById(String id) async {
    print('\nBuscando marcador con ID: $id');
    
    // Intentar primero en Firestore
    print('Buscando en Firestore...');
    final firestoreResult = await _firestoreService.getMarkerById(id);
    if (firestoreResult.isSuccess) {
      print('Marcador encontrado en Firestore');
      return firestoreResult;
    }

    // Si no se encuentra en Firestore, buscar en mock
    print('Buscando en mockup...');
    final mockResult = await _mockService.getMarkerById(id);
    if (mockResult.isSuccess) {
      print('Marcador encontrado en mockup');
    } else {
      print('Marcador no encontrado en ninguna fuente');
    }
    return mockResult;
  }

  @override
  Future<Result<MarkerModel, MarkerError>> getCurrentLocation() async {
    print('\nObteniendo ubicación actual...');
    // Usar el servicio mock para la ubicación actual ya que Firestore no lo implementa
    final result = await _mockService.getCurrentLocation();
    if (result.isSuccess) {
      print('Ubicación actual obtenida: ${result.success.position.latitude}, ${result.success.position.longitude}');
    } else {
      print('Error al obtener la ubicación actual');
    }
    return result;
  }

  // Método para guardar un nuevo lugar (solo en Firestore)
  Future<Result<MarkerModel, MarkerError>> savePlace(MarkerModel marker) async {
    print('\nGuardando nuevo lugar en Firestore...');
    print('ID: ${marker.id}');
    print('Título: ${marker.title}');
    print('Posición: ${marker.position.latitude}, ${marker.position.longitude}');
    
    final result = await _firestoreService.savePlace(marker);
    if (result.isSuccess) {
      print('Lugar guardado exitosamente');
    } else {
      print('Error al guardar el lugar');
    }
    return result;
  }

  // Método para eliminar un lugar (solo de Firestore)
  Future<Result<void, MarkerError>> deletePlace(String id) async {
    print('\nEliminando lugar con ID: $id');
    final result = await _firestoreService.deletePlace(id);
    if (result.isSuccess) {
      print('Lugar eliminado exitosamente');
    } else {
      print('Error al eliminar el lugar');
    }
    return result;
  }

  /// Obtiene todos los lugares guardados en Firestore
  Future<Result<List<MarkerModel>, MarkerError>> getAllFirestorePlaces() async {
    print('\nObteniendo todos los lugares de Firestore...');
    final result = await _firestoreService.getAllPlaces();
    if (result.isSuccess) {
      print('Total de lugares en Firestore: ${result.success.length}');
      for (var marker in result.success) {
        print('- ID: ${marker.id}, Título: ${marker.title}');
      }
    } else {
      print('Error al obtener los lugares de Firestore');
    }
    return result;
  }

  /// Obtiene todos los lugares (tanto de Firestore como mock)
  Future<Result<List<MarkerModel>, MarkerError>> getAllPlaces() async {
    try {
      print('\nObteniendo todos los lugares...');
      
      // Obtener lugares de ambas fuentes
      print('Obteniendo lugares del mockup...');
      final mockResult = await _mockService.getNearbyMarkers(
        latitude: 41.6560, // Centro de Zaragoza como punto de referencia
        longitude: -0.8773,
        radiusInMeters: 100000, // Radio muy grande para obtener todos
      );
      print('Lugares del mockup: ${mockResult.isSuccess ? mockResult.success.length : 'Error'}');

      print('\nObteniendo lugares de Firestore...');
      final firestoreResult = await _firestoreService.getAllPlaces();
      print('Lugares de Firestore: ${firestoreResult.isSuccess ? firestoreResult.success.length : 'Error'}');

      // Combinar resultados si ambos son exitosos
      if (mockResult.isSuccess && firestoreResult.isSuccess) {
        final combinedMarkers = [
          ...mockResult.success,
          ...firestoreResult.success,
        ];
        
        print('\nTotal de lugares combinados: ${combinedMarkers.length}');
        
        // Eliminar duplicados basados en ID
        final uniqueMarkers = combinedMarkers.fold<Map<String, MarkerModel>>(
          {},
          (map, marker) {
            map[marker.id] = marker;
            return map;
          },
        ).values.toList();

        print('Lugares únicos después de eliminar duplicados: ${uniqueMarkers.length}');
        print('\nDetalles de los lugares:');
        for (var marker in uniqueMarkers) {
          print('- ID: ${marker.id}, Tipo: ${marker.type}, Título: ${marker.title}, Posición: ${marker.position.latitude}, ${marker.position.longitude}');
        }

        return Success(uniqueMarkers);
      }

      // Si Firestore falla pero mock funciona, devolver solo mock
      if (mockResult.isSuccess) {
        print('\nUsando solo lugares del mockup debido a error en Firestore');
        return mockResult;
      }

      // Si mock falla pero Firestore funciona, devolver solo Firestore
      if (firestoreResult.isSuccess) {
        print('\nUsando solo lugares de Firestore debido a error en el mockup');
        return firestoreResult;
      }

      print('\nError al obtener lugares de ambas fuentes');
      return Failure(const MarkerError.serverError('Error al obtener todos los lugares'));
    } catch (e) {
      print('\nError inesperado: $e');
      return Failure(MarkerError.serverError(e.toString()));
    }
  }
} 