import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:result_dart/result_dart.dart';
import '../../domain/marker_model.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';
import '../../../accessibility/domain/accessibility_report_model.dart';
import '../../../accessibility/domain/i_accessibility_report_service.dart';
import '../../../accessibility/infrastructure/services/mock_accessibility_report_service.dart';
import '../../infrastructure/providers/map_filters_provider.dart';

class CustomMapMarker extends StatelessWidget {
  final MarkerModel marker;
  final bool isSelected;
  final VoidCallback onTap;
  // Add a static instance of the report service to get accessibility levels
  static final IAccessibilityReportService _reportService = MockAccessibilityReportService();

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
        final Color backgroundColor = isHighContrastMode 
            ? accessibilityProvider.getEnhancedColor(snapshot.data ?? Colors.grey)
            : snapshot.data ?? Colors.grey;
            
        final Color iconColor = isHighContrastMode
            ? (backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
            : Colors.white;
            
        final Color borderColor = isHighContrastMode 
            ? Colors.white
            : marker.borderColor;
        
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
          width: 2.0, // Borde más ancho para mejor visibilidad
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
      default:
        return 'Punto';
    }
  }

  BoxShape _getMarkerShape() {
    switch (marker.type) {
      case MarkerType.currentLocation:
        return BoxShape.circle;
      default:
        return BoxShape.circle;
    }
  }

  IconData _getMarkerIcon() {
    switch (marker.type) {
      case MarkerType.pointOfInterest:
        return Icons.accessible;
      case MarkerType.destination:
        return Icons.place;
      case MarkerType.currentLocation:
        return Icons.my_location;
      default:
        return Icons.location_on;
    }
  }

  Future<Color> _getMarkerColorAsync() async {
    if (isSelected) {
      return Colors.deepOrange;
    }

    if (marker.type == MarkerType.currentLocation) {
      return Colors.red;
    }

    final result = await _reportService.getAccessibilityLevelForMarker(marker.id);
    if (result.isSuccess()) {
      switch (result.getOrThrow()) {
        case AccessibilityLevel.good:
          return Colors.green;
        case AccessibilityLevel.medium:
          return Colors.yellow;
        case AccessibilityLevel.bad:
          return Colors.red;
      }
    }
    return Colors.grey;
  }
} 