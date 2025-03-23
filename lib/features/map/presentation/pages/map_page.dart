import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../application/marker_cubit.dart';
import '../../application/marker_state.dart';
import '../../domain/marker_model.dart';
import '../widgets/accessibility_filter.dart';
import '../widgets/custom_map_marker.dart';
import '../widgets/marker_detail_card.dart';
import '../../../accessibility/presentation/pages/accessibility_settings_page.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';
import '../../../../main.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarkerCubit()..initialize(),
      child: const MapView(),
    );
  }
}

class MapView extends StatelessWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    
    return Scaffold(
      body: BlocBuilder<MarkerCubit, MarkerState>(
        builder: (context, state) {
          return Stack(
            children: [
              // Mapa principal
              FlutterMap(
                options: MapOptions(
                  center: state.currentLocation?.position ?? 
                      const LatLng(41.6560, -0.8773), // Centro por defecto (Zaragoza)
                  zoom: 15,
                  onTap: (_, __) {
                    // Cerrar detalle del marcador si está abierto
                    if (state.hasSelectedMarker) {
                      context.read<MarkerCubit>().clearSelectedMarker();
                    }
                  },
                ),
                children: [
                  // Capa de mapa base - Usar un estilo de alto contraste si está activado
                  TileLayer(
                    urlTemplate: isHighContrastMode ? kHighContrastMapUrl : kDefaultMapUrl,
                    userAgentPackageName: 'com.example.app',
                    // Ajustar el brillo para alto contraste
                    tileBuilder: isHighContrastMode
                        ? (context, widget, tile) {
                            return ColorFiltered(
                              colorFilter: const ColorFilter.matrix(<double>[
                                1.2, 0, 0, 0, 0, // Aumentar brillo rojo
                                0, 1.2, 0, 0, 0, // Aumentar brillo verde
                                0, 0, 1.2, 0, 0, // Aumentar brillo azul
                                0, 0, 0, 1, 0,
                              ]),
                              child: widget,
                            );
                          }
                        : null,
                  ),
                  
                  // Capa de marcadores
                  MarkerLayer(
                    markers: _buildMarkers(context, state),
                  ),
                ],
              ),
              
              // Barra de búsqueda y filtros
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 0,
                right: 0,
                child: AccessibilityFilter(
                  onFilterChanged: (level) {
                    // Implementar filtrado por nivel
                  },
                ),
              ),
              
              // Indicador de carga
              if (state.isLoadingCurrentLocation || state.isLoadingNearbyMarkers)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              
              // Mostrar detalle del marcador seleccionado
              if (state.hasSelectedMarker)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: MarkerDetailCard(
                    marker: state.selectedMarker!,
                    onClose: () => context.read<MarkerCubit>().clearSelectedMarker(),
                    onGetDirections: () {
                      // Implementar navegación
                    },
                  ),
                ),
                
              // Botones de control de mapa
              Positioned(
                right: 16,
                bottom: state.hasSelectedMarker ? 220 : 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón para centrar en ubicación actual
                    FloatingActionButton(
                      heroTag: 'current_location',
                      mini: true,
                      backgroundColor: isHighContrastMode 
                          ? AccessibilityProvider.kButtonColor 
                          : Colors.white,
                      child: Icon(
                        Icons.my_location,
                        color: isHighContrastMode ? Colors.black : Colors.black87,
                      ),
                      onPressed: () {
                        context.read<MarkerCubit>().getCurrentLocation();
                      },
                    ),
                    const SizedBox(height: 8),
                    
                    // Botón para restaurar vista por defecto
                    FloatingActionButton(
                      heroTag: 'reset_view',
                      mini: true,
                      backgroundColor: isHighContrastMode 
                          ? AccessibilityProvider.kButtonColor 
                          : Colors.white,
                      child: Icon(
                        Icons.replay,
                        color: isHighContrastMode ? Colors.black : Colors.black87,
                      ),
                      onPressed: () {
                        // Implementar reset de vista
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Botón de accesibilidad
                    FloatingActionButton(
                      heroTag: 'accessibility',
                      mini: true,
                      backgroundColor: isHighContrastMode 
                          ? AccessibilityProvider.kAccentColor 
                          : Colors.white,
                      child: Icon(
                        Icons.accessibility_new,
                        color: isHighContrastMode ? Colors.black : Colors.black87,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccessibilitySettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Marker> _buildMarkers(BuildContext context, MarkerState state) {
    final List<Marker> markers = [];
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    
    // Añadir marcadores cercanos
    for (final model in state.nearbyMarkers) {
      markers.add(
        Marker(
          point: model.position,
          // Dar más espacio si estamos en modo de alto contraste
          width: isHighContrastMode ? model.width * 1.5 : model.width,
          height: isHighContrastMode ? model.height * 2.0 : model.height,
          child: CustomMapMarker(
            marker: model,
            isSelected: state.hasSelectedMarker && 
                        state.selectedMarker!.id == model.id,
            onTap: () {
              context.read<MarkerCubit>().selectMarkerById(model.id);
            },
          ),
        ),
      );
    }
    
    // Añadir marcador de ubicación actual si está disponible
    if (state.hasCurrentLocation) {
      final currentLocation = state.currentLocation!;
      markers.add(
        Marker(
          point: currentLocation.position,
          // Dar más espacio si estamos en modo de alto contraste
          width: isHighContrastMode ? currentLocation.width * 1.5 : currentLocation.width,
          height: isHighContrastMode ? currentLocation.height * 2.0 : currentLocation.height,
          child: CustomMapMarker(
            marker: currentLocation,
            onTap: () {
              context.read<MarkerCubit>().selectMarkerById(currentLocation.id);
            },
          ),
        ),
      );
    }
    
    return markers;
  }
} 