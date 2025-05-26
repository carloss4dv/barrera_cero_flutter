import 'package:open_route_service/open_route_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:result_type/result_type.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/route_segment_model.dart';
import '../../domain/route_error.dart';
import '../../../accessibility/domain/i_community_validation_service.dart';
import '../../../accessibility/domain/community_validation_model.dart';
import '../../domain/i_marker_service.dart';
import '../../domain/marker_model.dart';

class RouteService {
  final String _apiKey;
  final ICommunityValidationService _validationService;
  final IMarkerService _markerService;
  final String _baseUrl = 'https://api.openrouteservice.org/v2/directions/foot-walking';

  RouteService({
    String? apiKey,
    ICommunityValidationService? validationService,
    IMarkerService? markerService,
  })  : _apiKey = apiKey ?? '5b3ce3597851110001cf62486d95f18bd8e643c2ac4d3a485105fc4e',
        _validationService = validationService ?? GetIt.instance<ICommunityValidationService>(),
        _markerService = markerService ?? GetIt.instance<IMarkerService>();

  /// Obtiene una ruta adaptada entre dos puntos
  Future<Result<List<LatLng>, RouteError>> getAdaptedRoute({
    required LatLng start,
    required LatLng end,
    bool avoidStairs = true,
    bool preferRamps = true,
  }) async {
    try {
      print('Obteniendo ruta de Open Route Service...');
      print('Inicio: ${start.longitude},${start.latitude}');
      print('Fin: ${end.longitude},${end.latitude}');

      // Construir la URL con los parámetros correctos
      final url = Uri.https(
        'api.openrouteservice.org',
        '/v2/directions/foot-walking',
        {
          'api_key': _apiKey,
          'start': '${start.longitude},${start.latitude}',
          'end': '${end.longitude},${end.latitude}',
        },
      );
      
      // Hacer la petición HTTP con los headers de autenticación
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        },
      );
      
      if (response.statusCode != 200) {
        print('Error en la petición: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        throw Exception('Error en la petición: ${response.statusCode}');
      }

      // Decodificar la respuesta
      final data = json.decode(response.body);
      final coordinates = data['features'][0]['geometry']['coordinates'] as List;
      
      // Convertir las coordenadas a LatLng
      final route = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

      print('Ruta obtenida con ${route.length} puntos');

      // Convertir las coordenadas a segmentos de ruta
      final segments = await _createRouteSegments(route);

      // Convertir los segmentos a coordenadas, manteniendo todos los segmentos
      final allCoordinates = _segmentsToCoordinates(segments);
      print('Ruta generada con ${allCoordinates.length} puntos');

      return Success(allCoordinates);
    } catch (e) {
      print('Error al obtener la ruta: $e');
      if (e.toString().contains('API key')) {
        return Failure(RouteError(RouteErrorType.routeServiceError, 'API key inválida para Open Route Service'));
      } else if (e.toString().contains('network')) {
        return Failure(RouteError(RouteErrorType.routeServiceError, 'Error de conexión con el servicio de rutas'));
      } else {
        return Failure(RouteError(RouteErrorType.routeServiceError, e.toString()));
      }
    }
  }

  /// Crea segmentos de ruta a partir de las coordenadas
  Future<List<RouteSegment>> _createRouteSegments(List<LatLng> coordinates) async {
    print('\n=== Creando segmentos de ruta ===');
    final segments = <RouteSegment>[];
    
    // Obtener todas las validaciones de una vez para toda la ruta
    print('Obteniendo validaciones para la ruta completa...');
    final routeValidations = await _getValidationsForRoute(coordinates);
    print('Se encontraron ${routeValidations.length} validaciones para la ruta');
    
    for (int i = 0; i < coordinates.length - 1; i++) {
      final start = coordinates[i];
      final end = coordinates[i + 1];
      
      print('\nProcesando segmento ${i + 1}/${coordinates.length - 1}');
      print('Inicio: ${start.latitude},${start.longitude}');
      print('Fin: ${end.latitude},${end.longitude}');
      
      // Calcular distancia entre puntos
      final distance = const Distance().as(
        LengthUnit.Meter,
        start,
        end,
      );
      print('Distancia del segmento: ${distance.toStringAsFixed(2)} metros');

      // Obtener validaciones relevantes para este segmento
      print('Buscando validaciones relevantes para el segmento...');
      final segmentValidations = await _getRelevantValidationsForSegment(
        start,
        end,
        routeValidations,
      );
      print('Se encontraron ${segmentValidations.length} validaciones relevantes');

      // Crear segmento con características de accesibilidad basadas en validaciones
      final segment = RouteSegment(
        start: start,
        end: end,
        distance: distance,
        hasStairs: _hasStairs(segmentValidations),
        hasRamp: _hasRamp(segmentValidations),
        slope: RouteSegment.calculateSlope(start, end, distance),
      );

      print('Características del segmento:');
      print('- Tiene escaleras: ${segment.hasStairs}');
      print('- Tiene rampa: ${segment.hasRamp}');
      print('- Pendiente: ${segment.slope.toStringAsFixed(2)}%');

      segments.add(segment);
    }

    print('\n=== Filtrado de segmentos accesibles ===');
    print('Total de segmentos: ${segments.length}');
    
    // Filtrar segmentos según criterios de accesibilidad
    final accessibleSegments = segments.where((segment) {
      final isAccessible = segment.isAccessible(
        avoidStairs: true,
        preferRamps: true,
      );
      print('Segmento ${segments.indexOf(segment) + 1}: ${isAccessible ? "Accesible" : "No accesible"}');
      return isAccessible;
    }).toList();

    print('Segmentos accesibles encontrados: ${accessibleSegments.length}');
    return accessibleSegments;
  }

  /// Obtiene todas las validaciones para una ruta completa
  Future<List<CommunityValidationModel>> _getValidationsForRoute(List<LatLng> coordinates) async {
    try {
      print('\n=== Obteniendo validaciones para la ruta ===');
      
      // Calcular el punto medio de la ruta
      final midPoint = LatLng(
        coordinates.map((c) => c.latitude).reduce((a, b) => a + b) / coordinates.length,
        coordinates.map((c) => c.longitude).reduce((a, b) => a + b) / coordinates.length,
      );
      print('Punto medio de la ruta: ${midPoint.latitude},${midPoint.longitude}');

      // Buscar marcadores cercanos al punto medio de la ruta
      print('Buscando marcadores cercanos (radio: 100m)...');
      final nearbyMarkersResult = await _markerService.getNearbyMarkers(
        latitude: midPoint.latitude,
        longitude: midPoint.longitude,
        radiusInMeters: 100, // Aumentado de 50 a 100 metros
      );

      if (nearbyMarkersResult.isFailure) {
        print('Error al obtener marcadores cercanos');
        return [];
      }

      final nearbyMarkers = nearbyMarkersResult.success;
      print('Marcadores cercanos encontrados: ${nearbyMarkers.length}');

      final validations = <CommunityValidationModel>[];
      print('Obteniendo validaciones para cada marcador...');

      // Obtener validaciones para cada marcador cercano
      for (final marker in nearbyMarkers) {
        print('\nProcesando marcador: ${marker.id}');
        final markerValidationsResult = await _validationService.getValidationsForMarker(marker.id);
        
        markerValidationsResult.fold(
          (markerValidations) {
            print('Validaciones encontradas: ${markerValidations.length}');
            validations.addAll(markerValidations);
          },
          (error) => print('Error al obtener validaciones para marcador ${marker.id}: $error'),
        );
      }

      print('Total de validaciones obtenidas: ${validations.length}');
      return validations;
    } catch (e) {
      print('Error al obtener validaciones para ruta: $e');
      return [];
    }
  }

  /// Obtiene las validaciones relevantes para un segmento específico
  Future<List<CommunityValidationModel>> _getRelevantValidationsForSegment(
    LatLng start,
    LatLng end,
    List<CommunityValidationModel> allValidations,
  ) async {
    print('\n=== Buscando validaciones relevantes para el segmento ===');
    
    // Calcular el punto medio del segmento
    final midPoint = LatLng(
      (start.latitude + end.latitude) / 2,
      (start.longitude + end.longitude) / 2,
    );
    print('Punto medio del segmento: ${midPoint.latitude},${midPoint.longitude}');

    final relevantValidations = <CommunityValidationModel>[];
    print('Total de validaciones a procesar: ${allValidations.length}');

    for (final validation in allValidations) {
      // Solo considerar validaciones con suficientes votos
      final hasEnoughVotes = validation.positiveVotes + validation.negativeVotes >= validation.totalVotesNeeded;
      if (!hasEnoughVotes) {
        print('Validación ${validation.id} descartada: votos insuficientes');
        continue;
      }

      // Obtener el marcador asociado a la validación
      final markerResult = await _markerService.getMarkerById(validation.markerId);
      if (markerResult.isFailure) {
        print('Validación ${validation.id} descartada: error al obtener marcador');
        continue;
      }

      final marker = markerResult.success;
      if (marker == null) {
        print('Validación ${validation.id} descartada: marcador no encontrado');
        continue;
      }

      // Verificar si la validación está cerca del segmento
      final distance = const Distance().as(
        LengthUnit.Meter,
        midPoint,
        marker.position,
      );

      if (distance <= 100) { // Aumentado de 50 a 100 metros
        print('Validación ${validation.id} aceptada: distancia ${distance.toStringAsFixed(2)}m');
        relevantValidations.add(validation);
      } else {
        print('Validación ${validation.id} descartada: demasiado lejos (${distance.toStringAsFixed(2)}m)');
      }
    }

    print('Validaciones relevantes encontradas: ${relevantValidations.length}');
    return relevantValidations;
  }

  /// Verifica si hay escaleras según las validaciones
  bool _hasStairs(List<CommunityValidationModel> validations) {
    if (validations.isEmpty) {
      print('No hay validaciones para verificar escaleras');
      return false;
    }
    
    // Buscar validación específica de escaleras
    final stairsValidation = validations.firstWhere(
      (v) => v.questionType == ValidationQuestionType.rampExists,
      orElse: () => CommunityValidationModel(
        id: '',
        markerId: '',
        questionType: ValidationQuestionType.rampExists,
        positiveVotes: 0,
        negativeVotes: 0,
        totalVotesNeeded: 10,
        status: ValidationStatus.pending,
        votedUserIds: [],
      ),
    );    // Comparar votos positivos y negativos para determinar si hay escaleras
    final hasStairs = stairsValidation.negativeVotes > stairsValidation.positiveVotes;
    print('Verificación de escaleras: ${hasStairs ? "Sí" : "No"}');
    print('- Votos positivos: ${stairsValidation.positiveVotes}');
    print('- Votos negativos: ${stairsValidation.negativeVotes}');
    print('- Diferencia: ${stairsValidation.positiveVotes - stairsValidation.negativeVotes}');
    
    return hasStairs;
  }

  /// Verifica si hay rampa según las validaciones
  bool _hasRamp(List<CommunityValidationModel> validations) {
    if (validations.isEmpty) {
      print('No hay validaciones para verificar rampas');
      return true; // Por defecto, asumimos que hay rampa
    }
    
    // Buscar validación específica de rampa
    final rampValidation = validations.firstWhere(
      (v) => v.questionType == ValidationQuestionType.rampExists,
      orElse: () => CommunityValidationModel(
        id: '',
        markerId: '',
        questionType: ValidationQuestionType.rampExists,
        positiveVotes: 0,
        negativeVotes: 0,
        totalVotesNeeded: 10,
        status: ValidationStatus.pending,
        votedUserIds: [],
      ),
    );

    final hasRamp = rampValidation.positiveVotes > rampValidation.negativeVotes;
    print('Verificación de rampas: ${hasRamp ? "Sí" : "No"}');
    print('- Votos positivos: ${rampValidation.positiveVotes}');
    print('- Votos negativos: ${rampValidation.negativeVotes}');
    
    return hasRamp;
  }

  /// Convierte segmentos de ruta a coordenadas
  List<LatLng> _segmentsToCoordinates(List<RouteSegment> segments) {
    final coordinates = <LatLng>[];
    
    // Añadir el punto de inicio del primer segmento
    if (segments.isNotEmpty) {
      coordinates.add(segments.first.start);
    }

    // Añadir los puntos finales de cada segmento
    for (final segment in segments) {
      coordinates.add(segment.end);
    }

    return coordinates;
  }
} 