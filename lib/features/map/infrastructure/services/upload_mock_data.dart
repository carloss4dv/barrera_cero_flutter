import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/i_marker_service.dart';
import '../../domain/marker_model.dart';
import '../../domain/marker_metadata.dart';
import 'combined_marker_service.dart';
import 'dart:math';
import '../../../accessibility/domain/i_community_validation_service.dart';
import '../../../accessibility/domain/community_validation_model.dart';
import 'package:result_dart/result_dart.dart';

class MockDataUploader {
  final IMarkerService _markerService;
  final ICommunityValidationService _validationService;
  final Random _random = Random();
  final http.Client _client = http.Client();

  MockDataUploader({
    IMarkerService? markerService,
    ICommunityValidationService? validationService,
  })  : _markerService = markerService ?? GetIt.instance<IMarkerService>(),
        _validationService = validationService ?? GetIt.instance<ICommunityValidationService>();

  // Función para obtener lugares de Zaragoza usando Overpass API
  Future<List<Map<String, dynamic>>> _getZaragozaPlaces() async {
    final query = '''
      [out:json][timeout:25];
      area[name="Zaragoza"]->.zaragoza;
      (
        node["amenity"~"restaurant|bar|cafe|university|school|hospital|theatre|cinema|library|museum|park"]["name"](area.zaragoza);
        way["amenity"~"restaurant|bar|cafe|university|school|hospital|theatre|cinema|library|museum|park"]["name"](area.zaragoza);
        relation["amenity"~"restaurant|bar|cafe|university|school|hospital|theatre|cinema|library|museum|park"]["name"](area.zaragoza);
      );
      out body;
      >;
      out skel qt;
    ''';

    try {
      final response = await _client.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        },
        body: query,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final elements = data['elements'] as List;
        
        return elements.where((element) {
          final tags = element['tags'] as Map<String, dynamic>? ?? {};
          return tags['name'] != null && tags['name'].toString().trim().isNotEmpty;
        }).map((element) {
          final tags = element['tags'] as Map<String, dynamic>;
          final lat = element['lat'] as double? ?? 0.0;
          final lon = element['lon'] as double? ?? 0.0;
          
          return {
            'name': tags['name'] as String,
            'lat': lat,
            'lng': lon,
            'type': tags['amenity'] as String? ?? 'unknown',
          };
        }).toList();
      } else {
        print('Error al obtener datos de Overpass: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error al conectar con Overpass: $e');
      return [];
    }
  }

  // Función auxiliar para generar puntos de interés
  MarkerModel _generatePointOfInterest({
    required String id,
    required double lat,
    required double lng,
    required String title,
    required String description,
    required String type,
    required int accessibilityScore,
  }) {
    final hasRamp = accessibilityScore >= 3;
    final hasElevator = accessibilityScore >= 4;
    final hasAccessibleBathroom = accessibilityScore >= 3;
    final hasBrailleSignage = accessibilityScore >= 3;
    final hasAudioGuidance = accessibilityScore >= 4;
    final hasTactilePavement = accessibilityScore >= 3;

    final metadata = MarkerMetadata(
      hasRamp: hasRamp,
      hasElevator: hasElevator,
      hasAccessibleBathroom: hasAccessibleBathroom,
      hasBrailleSignage: hasBrailleSignage,
      hasAudioGuidance: hasAudioGuidance,
      hasTactilePavement: hasTactilePavement,
      additionalNotes: _getAccessibilityNotes(accessibilityScore),
      accessibilityScore: accessibilityScore,
    );

    return type == 'pointOfInterest'
        ? MarkerModel.pointOfInterest(
            id: id,
            position: LatLng(lat, lng),
            title: title,
            description: description,
            metadata: metadata,
          )
        : MarkerModel.destination(
            id: id,
            position: LatLng(lat, lng),
            title: title,
            description: description,
            metadata: metadata,
          );
  }

  String _getAccessibilityNotes(int score) {
    switch (score) {
      case 5:
        return 'Excelente accesibilidad en todo el recinto';
      case 4:
        return 'Buena accesibilidad con algunas limitaciones menores';
      case 3:
        return 'Accesibilidad media, con algunas áreas adaptadas';
      case 2:
        return 'Accesibilidad limitada, requiere mejoras';
      case 1:
        return 'Accesibilidad muy limitada';
      default:
        return 'Sin reportes de accesibilidad';
    }
  }

  // Función para generar votos de validación
  Future<void> _generateValidationVotes(String markerId, int accessibilityScore) async {
    final questionTypes = [
      ValidationQuestionType.rampExists,
      ValidationQuestionType.rampCondition,
      ValidationQuestionType.rampWidth,
      ValidationQuestionType.rampSlope,
      ValidationQuestionType.rampHandrails,
      ValidationQuestionType.rampLanding,
      ValidationQuestionType.rampObstacles,
      ValidationQuestionType.rampSurface,
      ValidationQuestionType.rampVisibility,
      ValidationQuestionType.rampMaintenance,
    ];

    for (final questionType in questionTypes) {
      // Crear la validación si no existe
      final createResult = await _validationService.createValidation(markerId, questionType);
      final validationCreated = createResult.fold(
        (validation) => true,
        (error) {
          print('Error al crear validación para ${markerId}: $error');
          return false;
        },
      );

      if (!validationCreated) continue;

      // Generar votos aleatorios basados en el nivel de accesibilidad
      final numVotes = _random.nextInt(5) + 6; // Entre 6 y 10 votos
      final positiveVotes = (numVotes * (accessibilityScore / 5)).round();
      final negativeVotes = numVotes - positiveVotes;

      // Simular votos de diferentes usuarios
      for (int i = 0; i < numVotes; i++) {
        final isPositive = i < positiveVotes;
        final userId = 'user_${_random.nextInt(1000)}';
        
        final voteResult = await _validationService.addVote(
          markerId,
          questionType,
          isPositive,
          userId,
        );

        voteResult.fold(
          (validation) => null,
          (error) => print('Error al añadir voto para ${markerId}: $error'),
        );
      }
    }
  }

  Future<void> uploadMockData() async {
    print('\n=== Iniciando subida de datos mock a Firestore ===');
    
    // Obtener lugares de Zaragoza desde OpenStreetMap
    final places = await _getZaragozaPlaces();
    print('Se encontraron ${places.length} lugares con nombre en Zaragoza');

    // Generar puntos de interés basados en los lugares obtenidos
    int creados = 0;
    for (int i = 0; i < places.length && creados < 200; i++) {
      final place = places[i];
      
      // Distribuir uniformemente los niveles de accesibilidad
      final int accessibilityScore = (creados % 5) + 1;

      final marker = _generatePointOfInterest(
        id: 'marker_${creados + 1}',
        lat: place['lat'],
        lng: place['lng'],
        title: place['name'],
        description: '${place['name']} - ${place['type']}',
        type: creados % 2 == 0 ? 'pointOfInterest' : 'destination',
        accessibilityScore: accessibilityScore,
      );

      try {
        // Guardar el marcador
        final result = await _markerService.savePlace(marker);
        if (result.isSuccess) {
          print('Marcador creado: ${marker.id} - ${place['name']}');
          
          // Generar votos de validación para el marcador
          await _generateValidationVotes(marker.id, accessibilityScore);
          print('Validaciones generadas para: ${marker.id}');
          creados++;
        } else {
          print('Error al crear marcador ${marker.id}: ${result.failure}');
        }
      } catch (e) {
        print('Error al procesar marcador ${marker.id}: $e');
      }
    }

    print('=== Subida de datos mock completada: $creados lugares creados ===\n');
  }
} 