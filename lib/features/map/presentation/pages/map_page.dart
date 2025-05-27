import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../application/marker_cubit.dart';
import '../../application/marker_state.dart';
import '../../domain/marker_model.dart';
import '../../domain/route_segment_model.dart';
import '../widgets/accessibility_filter.dart';
import '../widgets/custom_map_marker.dart';
import '../widgets/marker_detail_card.dart';
import '../../../accessibility/presentation/pages/accessibility_settings_page.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';
import '../../../accessibility/domain/accessibility_level.dart';
import '../../../challenges/presentation/widgets/challenges_panel.dart';
import '../../../../main.dart';
import '../../infrastructure/providers/map_filters_provider.dart';
import '../../infrastructure/services/run_upload_mock_data.dart';
import '../../../accessibility/infrastructure/services/run_upload_validation_mock_data.dart';
import '../../../auth/service/auth_service.dart';

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

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final ValueNotifier<bool> isChallengesPanelExpanded = ValueNotifier<bool>(false);
  final MapController _mapController = MapController();
  bool _isAuthenticated = false;
  String? _previousSelectedMarkerId;

  @override
  void initState() {
    super.initState();
    // Verificar estado de autenticación actual
    _updateAuthState();
    // Escuchar cambios de autenticación
    authService.authStateChanges.listen((user) {
      if (mounted) {
        _updateAuthState();
      }
    });
  }
    void _updateAuthState() {
    setState(() {
      _isAuthenticated = authService.currentUser != null;
      // Si el usuario cierra sesión y el panel está abierto, cerrarlo
      if (!_isAuthenticated && isChallengesPanelExpanded.value) {
        isChallengesPanelExpanded.value = false;
      }
    });
  }  /// Centra el mapa en la ubicación actual del usuario
  void _centerMapOnCurrentLocation(LatLng location) {
    final currentCenter = _mapController.camera.center;
    final distance = const Distance().as(LengthUnit.Meter, currentCenter, location);
    
    // Solo mover si la ubicación está lo suficientemente lejos (más de 50 metros)
    if (distance > 50) {
      // Centrar el mapa en la nueva ubicación con un zoom apropiado
      _mapController.move(location, 17.0);
    }
  }

  /// Ajusta el mapa para mostrar tanto la ubicación actual como el marcador seleccionado
  void _fitMapToBothLocations(LatLng currentLocation, LatLng selectedLocation) {
    // Calcular los límites para incluir ambas ubicaciones
    final double minLat = math.min(currentLocation.latitude, selectedLocation.latitude);
    final double maxLat = math.max(currentLocation.latitude, selectedLocation.latitude);
    final double minLng = math.min(currentLocation.longitude, selectedLocation.longitude);
    final double maxLng = math.max(currentLocation.longitude, selectedLocation.longitude);
      // Añadir un padding proporcional a la distancia
    final double distance = const Distance().as(LengthUnit.Meter, currentLocation, selectedLocation);
    
    // Calcular padding basado en la distancia
    double paddingFactor;
    if (distance < 1000) {
      paddingFactor = 0.3; // 30% para distancias cortas
    } else if (distance < 5000) {
      paddingFactor = 0.25; // 25% para distancias medias
    } else {
      paddingFactor = 0.2; // 20% para distancias largas
    }
    
    final double latPadding = (maxLat - minLat) * paddingFactor;
    final double lngPadding = (maxLng - minLng) * paddingFactor;
    
    // Si los puntos están muy cerca, usar un padding mínimo proporcional
    final double minPadding = distance < 1000 ? 0.003 : 0.002; // Más padding para distancias cortas
    final double finalLatPadding = math.max(latPadding, minPadding);
    final double finalLngPadding = math.max(lngPadding, minPadding);
    
    // Crear los bounds con padding
    final LatLngBounds bounds = LatLngBounds(
      LatLng(minLat - finalLatPadding, minLng - finalLngPadding),
      LatLng(maxLat + finalLatPadding, maxLng + finalLngPadding),
    );
    
    // Calcular el centro
    final LatLng center = LatLng(
      (bounds.north + bounds.south) / 2,
      (bounds.east + bounds.west) / 2,    );      // Calcular un zoom apropiado basado en la distancia ya calculada
    double zoom;
    
    if (distance < 300) {
      zoom = 16.0; // Muy cerca (reducido de 17.0)
    } else if (distance < 500) {
      zoom = 15.5; // Muy cerca-cerca (reducido de 16.5)
    } else if (distance < 800) {
      zoom = 15.0; // Cerca (reducido de 16.0)
    } else if (distance < 1200) {
      zoom = 14.5; // Cerca-media (reducido de 15.5)
    } else if (distance < 2000) {
      zoom = 14.0; // Media distancia (reducido de 15.0)
    } else if (distance < 3000) {
      zoom = 13.5; // Media-lejos (reducido de 14.5)
    } else if (distance < 5000) {
      zoom = 13.0; // Lejos (reducido de 14.0)
    } else if (distance < 8000) {
      zoom = 12.5; // Muy lejos (reducido de 13.5)
    } else if (distance < 12000) {
      zoom = 12.0; // Bastante lejos (reducido de 13.0)
    } else if (distance < 20000) {
      zoom = 11.5; // Muy lejos (reducido de 12.5)
    } else {
      zoom = 11.0; // Extremadamente lejos (reducido de 12.0)
    }
    
    // Mover el mapa al centro calculado con el zoom apropiado
    _mapController.move(center, zoom);
  }
  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
      return Scaffold(
      body: BlocBuilder<MarkerCubit, MarkerState>(
        builder: (context, state) {
          // Centrar el mapa cuando se obtenga la ubicación actual
          if (state.hasCurrentLocation) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _centerMapOnCurrentLocation(state.currentLocation!.position);
            });
          }
            // Ajustar el mapa cuando se selecciona un marcador diferente
          if (state.hasSelectedMarker && state.hasCurrentLocation) {
            final currentSelectedId = state.selectedMarker!.id;
            if (_previousSelectedMarkerId != currentSelectedId) {
              _previousSelectedMarkerId = currentSelectedId;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fitMapToBothLocations(
                  state.currentLocation!.position,
                  state.selectedMarker!.position,
                );
              });
            }
          } else if (!state.hasSelectedMarker) {
            // Reset previous selected marker when no marker is selected
            _previousSelectedMarkerId = null;
          }
          
          return Stack(children: [              // Mapa principal
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: state.currentLocation?.position ?? 
                      const LatLng(41.6560, -0.8773), // Centro por defecto (Zaragoza)
                  initialZoom: 15.0,
                  onTap: (_, __) {
                    // Cerrar detalle del marcador si está abierto
                    if (state.hasSelectedMarker) {
                      context.read<MarkerCubit>().clearSelectedMarker();
                    }
                    // Limpiar la ruta si está visible
                    if (state.hasRoute) {
                      context.read<MarkerCubit>().clearRoute();
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
                  
                  // Capa de ruta si existe
                  if (state.hasRoute)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.route!,
                          color: isHighContrastMode ? Colors.yellow : Colors.blue,
                          strokeWidth: 4,
                          gradientColors: _getRouteGradientColors(context, state.route!, isHighContrastMode),
                        ),
                      ],
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AccessibilityFilter(),
                        ),
                      ],
                    ),
                  ],
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
                
              // Botones de acción flotantes
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón para ubicación actual
                    FloatingActionButton(
                      heroTag: 'current_location',
                      mini: true,
                      backgroundColor: isHighContrastMode 
                          ? AccessibilityProvider.kButtonColor 
                          : Colors.white,
                      child: Icon(
                        Icons.my_location,
                        color: isHighContrastMode ? Colors.black : Colors.black87,
                      ),                      onPressed: () async {
                        await context.read<MarkerCubit>().getCurrentLocation();
                        // Obtener el estado actualizado después de cargar la ubicación
                        final currentState = context.read<MarkerCubit>().state;
                        if (currentState.hasCurrentLocation) {
                          // Centrar el mapa en la ubicación actual
                          _centerMapOnCurrentLocation(currentState.currentLocation!.position);
                          // Actualizar los marcadores cercanos
                          await context.read<MarkerCubit>().getNearbyMarkers(
                            latitude: currentState.currentLocation!.position.latitude,
                            longitude: currentState.currentLocation!.position.longitude,
                          );
                        }
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
                      ),                      onPressed: () {
                        // Centrar en la ubicación actual si está disponible
                        if (state.hasCurrentLocation) {
                          _centerMapOnCurrentLocation(state.currentLocation!.position);
                        } else {
                          // Si no hay ubicación actual, centrar en Zaragoza
                          _mapController.move(const LatLng(41.6560, -0.8773), 15.0);
                        }
                        // Limpiar marcador seleccionado y rutas
                        context.read<MarkerCubit>().clearSelectedMarker();
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
                      const SizedBox(height: 8),
                      // Botón de desafíos (solo visible si hay usuario autenticado)
                    if (_isAuthenticated)
                      FloatingActionButton(
                        heroTag: 'challenges',
                        mini: true,
                        backgroundColor: isHighContrastMode 
                            ? AccessibilityProvider.kAccentColor 
                            : Colors.white,
                        child: Icon(
                          Icons.emoji_events,
                          color: isHighContrastMode ? Colors.black : Colors.black87,
                        ),
                        onPressed: () {
                          // Toggle challenges panel
                          isChallengesPanelExpanded.value = !isChallengesPanelExpanded.value;
                        },
                      ),
                    
                    const SizedBox(height: 8),
                      // Botón del foro
                    FloatingActionButton(
                      heroTag: 'forum',
                      mini: true,
                      backgroundColor: isHighContrastMode 
                          ? AccessibilityProvider.kAccentColor 
                          : Colors.white,
                      child: Icon(
                        Icons.forum,
                        color: isHighContrastMode ? Colors.black : Colors.black87,
                      ),
                      onPressed: () {
                        if (_isAuthenticated) {
                          Navigator.pushNamed(context, '/forum');
                        } else {
                          // Mostrar diálogo para iniciar sesión
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Acceso al Foro'),
                              content: const Text(
                                'Debes iniciar sesión para acceder al foro de experiencias.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  child: const Text('Iniciar Sesión'),
                                ),
                              ],
                            ),
                          );
                        }
                      },                      ),
                      const SizedBox(height: 8),
                    
                    // Botón temporal para subir datos mock (oculto pero código preservado)
                    if (false) // Condición que siempre es falsa para ocultar el botón
                      FloatingActionButton(
                        heroTag: 'upload_mock',
                        mini: true,
                        backgroundColor: isHighContrastMode 
                            ? AccessibilityProvider.kAccentColor 
                            : Colors.white,
                        child: Icon(
                          Icons.cloud_upload,
                          color: isHighContrastMode ? Colors.black : Colors.black87,
                        ),
                        onPressed: () {
                          runUploadMockData();
                        },
                      ),
                  ],
                ),
              ),              // Challenges Panel (solo visible si hay usuario autenticado)
              if (_isAuthenticated)
                ValueListenableBuilder<bool>(
                  valueListenable: isChallengesPanelExpanded,
                  builder: (context, isExpanded, _) {
                    return ChallengesPanel(
                      isExpanded: isExpanded,
                      onClose: () {
                        isChallengesPanelExpanded.value = false;
                      },
                    );
                  },
                ),

              // Indicador de carga para la ruta
              if (state.isLoadingRoute)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Card(
                      color: isHighContrastMode 
                          ? AccessibilityProvider.kButtonColor 
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isHighContrastMode ? Colors.black : Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Generando ruta accesible...',
                              style: TextStyle(
                                color: isHighContrastMode ? Colors.black : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Esto puede tardar unos segundos',
                              style: TextStyle(
                                color: isHighContrastMode ? Colors.black : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Marker> _buildMarkers(BuildContext context, MarkerState state) {
    print('\n=== Construyendo marcadores ===');
    print('Estado de los marcadores cercanos:');
    print('- Cargando: ${state.isLoadingNearbyMarkers}');
    print('- Error: ${state.hasErrorNearbyMarkers}');
    print('- Número de marcadores: ${state.nearbyMarkers.length}');
    
    final List<Marker> markers = [];
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    
    // Añadir marcadores cercanos
    for (final model in state.nearbyMarkers) {
      print('- Añadiendo marcador: ${model.title} (${model.position.latitude}, ${model.position.longitude})');
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
      print('- Añadiendo ubicación actual: (${currentLocation.position.latitude}, ${currentLocation.position.longitude})');
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
    
    print('Total de marcadores construidos: ${markers.length}');
    return markers;
  }
  List<Color> _getRouteGradientColors(BuildContext context, List<LatLng> route, bool isHighContrastMode) {
    final colors = <Color>[];
    
    // Para cada punto de la ruta
    for (int i = 0; i < route.length; i++) {
      // Si no es el último punto, evaluar el segmento
      if (i < route.length - 1) {
        final start = route[i];
        final end = route[i + 1];
        
        // Crear un segmento temporal para evaluar su accesibilidad
        final segment = RouteSegment(
          start: start,
          end: end,
          distance: const Distance().as(LengthUnit.Meter, start, end),
        );
        
        // Obtener el nivel de accesibilidad del segmento
        final level = segment.getAccessibilityLevel(
          avoidStairs: true,
          preferRamps: true,
        );
        
        // Asignar color según el nivel de accesibilidad
        final Color segmentColor = switch (level) {
          AccessibilityLevel.good => isHighContrastMode 
              ? const Color(0xFF4CAF50) // Verde brillante
              : Colors.green,
          AccessibilityLevel.medium => isHighContrastMode 
              ? const Color(0xFFFFD600) // Ámbar brillante
              : Colors.amber,
          AccessibilityLevel.bad => isHighContrastMode 
              ? const Color(0xFFFF5252) // Rojo brillante
              : Colors.red,
        };
        
        colors.add(segmentColor);
      } else {
        // Para el último punto, usar el mismo color que el último segmento
        colors.add(colors.last);
      }
    }
    
    return colors;
  }
}