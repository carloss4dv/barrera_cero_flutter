import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:get_it/get_it.dart';
import 'package:result_type/result_type.dart';

import '../domain/i_marker_service.dart';
import '../domain/marker_model.dart';
import 'marker_state.dart';

/// Cubit para gestionar los marcadores en el mapa
class MarkerCubit extends Cubit<MarkerState> {
  final IMarkerService _markerService;

  MarkerCubit({
    IMarkerService? markerService,
  })  : _markerService = markerService ?? GetIt.instance<IMarkerService>(),
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
      emit(state.copyWith(
        selectedMarkerState: DataState.success(result.success),
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
    ));
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
} 