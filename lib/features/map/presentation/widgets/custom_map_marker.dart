import 'package:flutter/material.dart';
import '../../domain/marker_model.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isSelected ? marker.width * 1.2 : marker.width,
        height: isSelected ? marker.height * 1.2 : marker.height,
        decoration: BoxDecoration(
          color: _getMarkerColor(),
          shape: _getMarkerShape(),
          border: Border.all(
            color: marker.borderColor,
            width: marker.borderWidth,
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
          child: Icon(
            _getMarkerIcon(),
            color: Colors.white,
            size: isSelected ? 24 : 20,
          ),
        ),
      ),
    );
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