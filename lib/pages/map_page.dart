import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../features/map/application/marker_cubit.dart';
import '../features/map/application/marker_state.dart';
import '../features/map/domain/marker_model.dart';
import '../main.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MarkerCubit>()..initialize(),
      child: const MapView(),
    );
  }
}

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MarkerCubit, MarkerState>(
        builder: (context, state) {
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  center: state.currentLocation?.position ?? const LatLng(41.6560, -0.8773), // Centro predeterminado en Plaza del Pilar, Zaragoza
                  zoom: 15,
                  onTap: (_, point) => {
                    // Cerrar el detalle del marcador si está abierto
                    if (state.hasSelectedMarker)
                      context.read<MarkerCubit>().clearSelectedMarker()
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: _buildMarkers(context, state),
                  ),
                ],
              ),
              if (state.isLoadingCurrentLocation || state.isLoadingNearbyMarkers)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              if (state.hasErrorCurrentLocation)
                Center(
                  child: ErrorWidget(
                    message: state.currentLocationState.errorMessage ?? 'Error al obtener la ubicación',
                    onRetry: () => context.read<MarkerCubit>().retryGetCurrentLocation(),
                  ),
                ),
              if (state.hasErrorNearbyMarkers)
                Center(
                  child: ErrorWidget(
                    message: state.nearbyMarkersState.errorMessage ?? 'Error al obtener los marcadores',
                    onRetry: () => context.read<MarkerCubit>().retryGetNearbyMarkers(),
                  ),
                ),
              if (state.hasSelectedMarker)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: MarkerDetailCard(marker: state.selectedMarker!),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Recargar la ubicación actual
          context.read<MarkerCubit>().getCurrentLocation();
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  List<Marker> _buildMarkers(BuildContext context, MarkerState state) {
    final List<Marker> markers = [];

    // Añadir marcadores cercanos
    for (final marker in state.nearbyMarkers) {
      markers.add(
        Marker(
          point: marker.position,
          width: marker.width,
          height: marker.height,
          child: GestureDetector(
            onTap: () => context.read<MarkerCubit>().selectMarkerById(marker.id),
            child: Container(
              decoration: BoxDecoration(
                color: marker.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: marker.borderColor,
                  width: marker.borderWidth,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Añadir la ubicación actual si está disponible
    if (state.hasCurrentLocation) {
      final currentLocation = state.currentLocation!;
      markers.add(
        Marker(
          point: currentLocation.position,
          width: currentLocation.width,
          height: currentLocation.height,
          child: Container(
            decoration: BoxDecoration(
              color: currentLocation.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: currentLocation.borderColor,
                width: currentLocation.borderWidth,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }
}

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorWidget({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class MarkerDetailCard extends StatelessWidget {
  final MarkerModel marker;

  const MarkerDetailCard({super.key, required this.marker});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              marker.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (marker.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(marker.description),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tipo: ${_markerTypeToString(marker.type)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'ID: ${marker.id}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _markerTypeToString(MarkerType type) {
    switch (type) {
      case MarkerType.currentLocation:
        return 'Ubicación Actual';
      case MarkerType.pointOfInterest:
        return 'Punto de Interés';
      case MarkerType.destination:
        return 'Destino';
      default:
        return 'Desconocido';
    }
  }
} 