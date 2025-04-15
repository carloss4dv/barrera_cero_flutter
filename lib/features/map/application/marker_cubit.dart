import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:get_it/get_it.dart';
import 'package:result_type/result_type.dart';

import '../domain/i_marker_service.dart';
import '../domain/marker_model.dart';
import '../domain/route_error.dart';
import '../infrastructure/services/route_service.dart';
import 'marker_state.dart';

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

  /// Selecciona un marcador por su ID
  Future<void> selectMarkerById(String id) async {
    emit(state.copyWith(
      selectedMarkerState: const DataState.loading(),
    ));

    final result = await _markerService.getMarkerById(id);

    if (result.isSuccess) {
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