import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../../domain/marker_model.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';
import '../../../accessibility/domain/accessibility_report_model.dart';
import '../../../accessibility/domain/i_accessibility_report_service.dart';
import '../../infrastructure/providers/map_filters_provider.dart';

class CustomMapMarker extends StatelessWidget {
  final MarkerModel marker;
  final bool isSelected;
  final VoidCallback onTap;
  // Get service from dependency injection instead of static instance
  static final IAccessibilityReportService _reportService = GetIt.instance<IAccessibilityReportService>();

  const CustomMapMarker({
    Key? key,
    required this.marker,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final mapFiltersProvider = Provider.of<MapFiltersProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    
    // Verificar si el marcador debe mostrarse según los filtros
    if (!mapFiltersProvider.shouldShowMarker(marker.metadata.toJson())) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Color>(
      future: _getMarkerColorAsync(),
      builder: (context, snapshot) {
        // Color de fondo: usar el color del snapshot si está disponible,
        // o el color del marcador como fallback (nunca usar gris como valor por defecto)
        final Color backgroundColor = isHighContrastMode 
            ? accessibilityProvider.getEnhancedColor(snapshot.data ?? marker.color)
            : snapshot.data ?? marker.color;
            
        // Color del icono: calcular basado en la luminosidad del fondo para mejor contraste
        final Color iconColor = isHighContrastMode
            ? (backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
            : Colors.white;
            
        // Color del borde: usar blanco en modo alto contraste, o el borderColor del marcador
        final Color borderColor = isHighContrastMode 
            ? Colors.white
            : marker.borderColor;
        
        // Widget del marcador según modo de accesibilidad
        final Widget markerWidget = isHighContrastMode
            ? SizedBox(
                width: isSelected ? marker.width * 1.5 : marker.width * 1.3,
                height: isSelected ? marker.height * 2.0 : marker.height * 1.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMarkerDot(backgroundColor, borderColor, iconColor),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        _getMarkerTypeText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : _buildMarkerDot(backgroundColor, borderColor, iconColor);
        
        return GestureDetector(
          onTap: onTap,
          child: markerWidget,
        );
      },
    );
  }
  
  Widget _buildMarkerDot(Color backgroundColor, Color borderColor, Color iconColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isSelected ? marker.width * 1.2 : marker.width,
      height: isSelected ? marker.height * 1.2 : marker.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: _getMarkerShape(),
        border: Border.all(
          color: borderColor,
          width: marker.borderWidth, // Usar el ancho de borde del modelo
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Center(
        child: Semantics(
          label: marker.title.isNotEmpty ? marker.title : marker.type.toString(),
          child: Icon(
            _getMarkerIcon(),
            color: iconColor,
            size: isSelected ? 24 : 20,
          ),
        ),
      ),
    );
  }
  String _getMarkerTypeText() {
    switch (marker.type) {
      case MarkerType.pointOfInterest:
        return 'Accesible';
      case MarkerType.destination:
        return 'Destino';
      case MarkerType.currentLocation:
        return 'Actual';
    }
  }
  BoxShape _getMarkerShape() {
    switch (marker.type) {
      case MarkerType.currentLocation:
        return BoxShape.circle;
      case MarkerType.pointOfInterest:
        return BoxShape.circle;
      case MarkerType.destination:
        return BoxShape.circle;
    }
  }
  IconData _getMarkerIcon() {
    switch (marker.type) {
      case MarkerType.pointOfInterest:
        return Icons.accessible_forward;
      case MarkerType.destination:
        return Icons.location_on;
      case MarkerType.currentLocation:
        return Icons.my_location;
    }
  }

  Future<Color> _getMarkerColorAsync() async {
    // Si el marcador está seleccionado, usar un color destacado
    if (isSelected) {
      return Colors.deepOrange;
    }

    // Si es el marcador de ubicación actual, usar rojo
    if (marker.type == MarkerType.currentLocation) {
      return Colors.red;
    }

    // Primero comprobar si tenemos un accessibilityScore en los metadatos
    // y usar eso para determinar el color
    final score = marker.metadata.accessibilityScore;
    if (score > 0) {
      if (score >= 4) {
        return Colors.green; // Buena accesibilidad (4-5)
      } else if (score >= 2) {
        return Colors.orange; // Accesibilidad media (2-3)
      } else {
        return Colors.red; // Mala accesibilidad (1)
      }
    }

    // Como respaldo, intentar obtener el nivel de accesibilidad del servicio
    final result = await _reportService.getAccessibilityLevelForMarker(marker.id);
    if (result.isSuccess()) {
      // Asignar colores según el nivel de accesibilidad
      switch (result.getOrThrow()) {
        case AccessibilityLevel.good:
          return Colors.green;
        case AccessibilityLevel.medium:
          return Colors.orange;
        case AccessibilityLevel.bad:
          return Colors.red;
      }
    }
    
    // Si no hay reportes o hay un error, usar el color definido en el modelo
    return marker.color;
  }
} 