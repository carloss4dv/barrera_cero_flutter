import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/marker_model.dart';
import '../../../accessibility/presentation/providers/accessibility_provider.dart';

class CustomMapMarker extends StatelessWidget {
  final MarkerModel marker;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomMapMarker({
    Key? key,
    required this.marker,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final isHighContrastMode = accessibilityProvider.highContrastMode;
    
    // Usar el color original pero con mayor contraste si está en modo alto contraste
    final Color originalColor = _getMarkerColor();
    final Color backgroundColor = isHighContrastMode 
        ? accessibilityProvider.getEnhancedColor(originalColor)
        : originalColor;
        
    // Determinar el color del icono basado en la luminosidad del fondo
    final Color iconColor = isHighContrastMode
        ? (backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
        : Colors.white;
        
    // Borde con mayor contraste
    final Color borderColor = isHighContrastMode 
        ? Colors.white
        : marker.borderColor;
    
    // Añadir un texto debajo del marcador en modo de alto contraste
    final Widget markerWidget = isHighContrastMode
        ? SizedBox(
            width: isSelected ? marker.width * 1.5 : marker.width * 1.3,
            height: isSelected ? marker.height * 2.0 : marker.height * 1.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMarkerDot(backgroundColor, borderColor, iconColor),
                const SizedBox(height: 2),
                // Añadir texto descriptivo debajo del marcador
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

  Color _getMarkerColor() {
    if (isSelected) {
      return Colors.deepOrange;
    }

    switch (marker.type) {
      case MarkerType.pointOfInterest:
        return Colors.orange;
      case MarkerType.destination:
        return Colors.amber;
      case MarkerType.currentLocation:
        return Colors.red;
      default:
        return marker.color;
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
} 