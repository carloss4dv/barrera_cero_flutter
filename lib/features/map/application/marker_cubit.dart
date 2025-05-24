import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:get_it/get_it.dart';
import 'package:result_type/result_type.dart';
import 'package:result_dart/result_dart.dart' as result_dart;

import '../domain/i_marker_service.dart';
import '../domain/marker_model.dart';
import '../domain/route_error.dart';
import '../infrastructure/services/route_service.dart';
import 'marker_state.dart';
import '../../accessibility/domain/i_accessibility_report_service.dart';
import '../../accessibility/domain/i_community_validation_service.dart';

/// Cubit para gestionar los marcadores en el mapa
class MarkerCubit extends Cubit<MarkerState> {
  final IMarkerService _markerService;
  final RouteService _routeService;

  MarkerCubit({
    IMarkerService? markerService,
    RouteService? routeService,
  })  : _markerService = markerService ?? GetIt.instance<IMarkerService>(),
        _routeService = routeService ?? RouteService(),
        super(MarkerState.initial());

  /// Inicializa el cubit cargando la ubicación actual y los marcadores cercanos
  Future<void> initialize() async {
    await getCurrentLocation();
    if (state.hasCurrentLocation) {
      await getNearbyMarkers(
        latitude: state.currentLocation!.position.latitude,
        longitude: state.currentLocation!.position.longitude,
      );
    }
  }

  /// Obtiene los marcadores cercanos a una ubicación
  Future<void> getNearbyMarkers({
    required double latitude,
    required double longitude,
    double? radiusInMeters,
  }) async {
    emit(state.copyWith(
      nearbyMarkersState: const DataState.loading(),
    ));

    final radius = radiusInMeters ?? state.searchRadius;

    final result = await _markerService.getNearbyMarkers(
      latitude: latitude,
      longitude: longitude,
      radiusInMeters: radius,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        nearbyMarkersState: DataState.success(result.success),
      ));
    } else {
      String errorMessage;
      switch (result.failure) {
        case MarkerError.serverError:
          errorMessage = 'Error del servidor al obtener marcadores';
          break;
        case MarkerError.locationPermissionDenied:
          errorMessage = 'Permiso de ubicación denegado';
          break;
        default:
          errorMessage = 'Error desconocido al obtener marcadores';
      }
      emit(state.copyWith(
        nearbyMarkersState: DataState.error(errorMessage),
      ));
    }
  }

  /// Obtiene la ubicación actual del usuario
  Future<void> getCurrentLocation() async {
    emit(state.copyWith(
      currentLocationState: const DataState.loading(),
    ));

    final result = await _markerService.getCurrentLocation();

    if (result.isSuccess) {
      emit(state.copyWith(
        currentLocationState: DataState.success(result.success),
      ));
    } else {
      String errorMessage;
      switch (result.failure) {
        case MarkerError.locationPermissionDenied:
          errorMessage = 'Permiso de ubicación denegado';
          break;
        case MarkerError.locationServiceDisabled:
          errorMessage = 'Servicio de ubicación desactivado';
          break;
        default:
          errorMessage = 'Error al obtener la ubicación actual';
      }
      emit(state.copyWith(
        currentLocationState: DataState.error(errorMessage),
      ));
    }
  }
  /// Selecciona un marcador por su ID y registra todos sus datos por consola
  Future<void> selectMarkerById(String id) async {
    print('======== INFORMACIÓN DETALLADA DEL LUGAR SELECCIONADO ========');
    print('ID del marcador: $id');
    
    emit(state.copyWith(
      selectedMarkerState: const DataState.loading(),
    ));

    final result = await _markerService.getMarkerById(id);

    if (result.isSuccess) {
      final marker = result.success;
      
      // Log de información básica del marcador
      print('\n----- DATOS BÁSICOS -----');
      print('Título: ${marker.title}');
      print('Descripción: ${marker.description}');
      print('Tipo: ${marker.type.toString()}');
      print('Posición: Lat ${marker.position.latitude}, Lng ${marker.position.longitude}');
      
      // Log de metadatos de accesibilidad
      print('\n----- METADATOS DE ACCESIBILIDAD -----');
      print('Rampa: ${marker.metadata.hasRamp ? 'Sí' : 'No'}');
      print('Ascensor: ${marker.metadata.hasElevator ? 'Sí' : 'No'}');
      print('Baño accesible: ${marker.metadata.hasAccessibleBathroom ? 'Sí' : 'No'}');
      print('Señalización Braille: ${marker.metadata.hasBrailleSignage ? 'Sí' : 'No'}');
      print('Guía de audio: ${marker.metadata.hasAudioGuidance ? 'Sí' : 'No'}');
      print('Pavimento táctil: ${marker.metadata.hasTactilePavement ? 'Sí' : 'No'}');
      print('Puntuación de accesibilidad: ${marker.metadata.accessibilityScore}/10');
      
      if (marker.metadata.additionalNotes.isNotEmpty) {
        print('Notas adicionales: ${marker.metadata.additionalNotes}');
      }
      
      // Obtener reportes de accesibilidad
      try {
        final reportService = GetIt.instance<IAccessibilityReportService>();
        final reportResult = await reportService.getReportsForMarker(id);
        
        reportResult.fold(
          (reports) {
            print('\n----- REPORTES DE ACCESIBILIDAD (${reports.length}) -----');
            if (reports.isEmpty) {
              print('No hay reportes de accesibilidad.');
            } else {
              for (var i = 0; i < reports.length; i++) {
                final report = reports[i];
                print('Reporte #${i+1}:');
                print('  ID: ${report.id}');
                print('  Usuario: ${report.userId}');
                print('  Nivel: ${report.level.toString()}');
                print('  Comentarios: ${report.comments}');
              }
            }
          },
          (error) {
            print('Error al cargar reportes: ${error.message}');
          },
        );
      } catch (e) {
        print('Error al obtener reportes: $e');
      }
      
      // Obtener validaciones de la comunidad
      try {
        final validationService = GetIt.instance<ICommunityValidationService>();
        final validationResult = await validationService.getValidationsForMarker(id);
        
        validationResult.fold(
          (validations) {
            print('\n----- VALIDACIONES DE LA COMUNIDAD (${validations.length}) -----');
            if (validations.isEmpty) {
              print('No hay validaciones de la comunidad.');
            } else {
              for (var i = 0; i < validations.length; i++) {
                final validation = validations[i];
                print('Validación #${i+1}:');
                print('  Tipo de pregunta: ${validation.questionType.toString()}');
                print('  Votos positivos: ${validation.positiveVotes}');
                print('  Votos negativos: ${validation.negativeVotes}');
                print('  Estado: ${validation.status.toString()}');
                print('  Progreso: ${(validation.getProgress() * 100).toStringAsFixed(1)}%');
              }
            }
          },
          (error) {
            print('Error al cargar validaciones: $error');
          },
        );
      } catch (e) {
        print('Error al obtener validaciones: $e');
      }
      
      print('\n======== FIN DE INFORMACIÓN DEL LUGAR ========\n');
      
      // Limpiar los marcadores cercanos y mantener solo el seleccionado
      emit(state.copyWith(
        selectedMarkerState: DataState.success(result.success),
        nearbyMarkersState: DataState.success([result.success]),
      ));
    } else {
      String errorMessage;
      switch (result.failure) {
        case MarkerError.notFound:
          errorMessage = 'Marcador no encontrado';
          break;
        case MarkerError.serverError:
          errorMessage = 'Error del servidor al obtener el marcador';
          break;
        default:
          errorMessage = 'Error desconocido al obtener el marcador';
      }
      print('Error al seleccionar marcador: $errorMessage');
      emit(state.copyWith(
        selectedMarkerState: DataState.error(errorMessage),
      ));
    }
  }

  /// Cambia el radio de búsqueda para los marcadores cercanos
  void setSearchRadius(double radius) {
    emit(state.copyWith(searchRadius: radius));
    
    // Si tenemos ubicación actual, actualizamos los marcadores con el nuevo radio
    if (state.hasCurrentLocation) {
      getNearbyMarkers(
        latitude: state.currentLocation!.position.latitude,
        longitude: state.currentLocation!.position.longitude,
        radiusInMeters: radius,
      );
    }
  }

  /// Limpia el marcador seleccionado
  void clearSelectedMarker() {
    emit(state.copyWith(
      selectedMarkerState: const DataState.idle(),
      routeState: const DataState.idle(),
    ));
    
    // Si tenemos ubicación actual, volvemos a cargar los marcadores cercanos
    if (state.hasCurrentLocation) {
      getNearbyMarkers(
        latitude: state.currentLocation!.position.latitude,
        longitude: state.currentLocation!.position.longitude,
      );
    }
  }

  /// Reintenta obtener la ubicación actual después de un error
  Future<void> retryGetCurrentLocation() async {
    if (state.hasErrorCurrentLocation) {
      await getCurrentLocation();
    }
  }

  /// Reintenta obtener los marcadores cercanos después de un error
  Future<void> retryGetNearbyMarkers() async {
    if (state.hasErrorNearbyMarkers && state.hasCurrentLocation) {
      await getNearbyMarkers(
        latitude: state.currentLocation!.position.latitude,
        longitude: state.currentLocation!.position.longitude,
      );
    }
  }

  /// Obtiene una ruta adaptada entre la ubicación actual y un destino
  Future<void> getRouteToDestination(MarkerModel destination) async {
    if (!state.hasCurrentLocation) {
      emit(state.copyWith(
        routeState: const DataState.error('No se ha podido obtener la ubicación actual'),
      ));
      return;
    }

    emit(state.copyWith(
      routeState: const DataState.loading(),
    ));

    final result = await _routeService.getAdaptedRoute(
      start: state.currentLocation!.position,
      end: destination.position,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        routeState: DataState.success(result.success),
      ));
    } else {
      String errorMessage;
      switch (result.failure.type) {
        case RouteErrorType.routeServiceError:
          errorMessage = result.failure.message ?? 'Error al obtener la ruta del servicio';
          break;
        case RouteErrorType.currentLocationError:
          errorMessage = 'No se pudo obtener la ubicación actual';
          break;
        case RouteErrorType.noAccessibleRoute:
          errorMessage = 'No hay ruta accesible disponible';
          break;
        default:
          errorMessage = 'Error desconocido al obtener la ruta';
      }
      emit(state.copyWith(
        routeState: DataState.error(errorMessage),
      ));
    }
  }

  /// Limpia la ruta actual
  void clearRoute() {
    emit(state.copyWith(
      routeState: const DataState.idle(),
    ));
  }
}