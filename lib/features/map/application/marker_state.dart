import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/marker_model.dart';

part 'marker_state.freezed.dart';

/// Estado para la gestión de marcadores
@freezed
abstract class MarkerState with _$MarkerState {
  const MarkerState._(); // Constructor privado para hacer la clase extensible

  const factory MarkerState({
    required DataState<List<MarkerModel>> nearbyMarkersState,
    required DataState<MarkerModel> currentLocationState,
    required DataState<MarkerModel> selectedMarkerState,
    @Default(1000.0) double searchRadius,
  }) = _MarkerState;

  // Getters auxiliares para estados derivados
  
  // Estados para marcadores cercanos
  bool get isLoadingNearbyMarkers => nearbyMarkersState.isLoading;
  bool get hasErrorNearbyMarkers => nearbyMarkersState.hasError;
  bool get hasNearbyMarkers => nearbyMarkersState.isSuccess && 
      nearbyMarkersState.data != null && 
      nearbyMarkersState.data!.isNotEmpty;
  List<MarkerModel> get nearbyMarkers => nearbyMarkersState.data ?? [];
  
  // Estados para ubicación actual
  bool get isLoadingCurrentLocation => currentLocationState.isLoading;
  bool get hasErrorCurrentLocation => currentLocationState.hasError;
  bool get hasCurrentLocation => currentLocationState.isSuccess && currentLocationState.data != null;
  MarkerModel? get currentLocation => currentLocationState.data;
  
  // Estados para marcador seleccionado
  bool get isLoadingSelectedMarker => selectedMarkerState.isLoading;
  bool get hasErrorSelectedMarker => selectedMarkerState.hasError;
  bool get hasSelectedMarker => selectedMarkerState.isSuccess && selectedMarkerState.data != null;
  MarkerModel? get selectedMarker => selectedMarkerState.data;

  // Estado inicial
  factory MarkerState.initial() => const MarkerState(
    nearbyMarkersState: DataState.idle(),
    currentLocationState: DataState.idle(),
    selectedMarkerState: DataState.idle(),
    searchRadius: 1000.0,
  );
}

/// Estado genérico para manejar operaciones asíncronas
@freezed
abstract class DataState<T> with _$DataState<T> {
  const DataState._();

  const factory DataState.idle() = _Idle<T>;
  const factory DataState.loading() = _Loading<T>;
  const factory DataState.error([String? message]) = _Error<T>;
  const factory DataState.success(T data) = _Success<T>;

  bool get isIdle => this is _Idle<T>;
  bool get isLoading => this is _Loading<T>;
  bool get hasError => this is _Error<T>;
  bool get isSuccess => this is _Success<T>;

  String? get errorMessage => hasError ? (this as _Error<T>).message : null;
  T? get data => isSuccess ? (this as _Success<T>).data : null;
} 