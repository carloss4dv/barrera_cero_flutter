import 'package:flutter/foundation.dart';

class MapFiltersProvider extends ChangeNotifier {
  int _accessibilityLevel = 0;
  Map<String, bool> _metadataFilters = {
    'hasRamp': false,
    'hasElevator': false,
    'hasAccessibleBathroom': false,
    'hasBrailleSignage': false,
    'hasAudioGuidance': false,
    'hasTactilePavement': false,
  };

  int get accessibilityLevel => _accessibilityLevel;
  Map<String, bool> get metadataFilters => Map.unmodifiable(_metadataFilters);

  void updateAccessibilityLevel(int level) {
    _accessibilityLevel = level;
    notifyListeners();
  }

  void updateFilters(Map<String, bool> filters) {
    _metadataFilters = Map.from(filters);
    notifyListeners();
  }

  bool shouldShowMarker(Map<String, dynamic> metadata) {
    // Si es el marcador de ubicación actual, siempre mostrarlo
    if (metadata['type'] == 'currentLocation') {
      return true;
    }

    // Si no hay filtros activos, mostrar todos los marcadores
    if (_accessibilityLevel == 0 && !_metadataFilters.values.any((value) => value)) {
      return true;
    }

    // Verificar nivel de accesibilidad
    if (_accessibilityLevel > 0) {
      final score = metadata['accessibilityScore'] as int? ?? 0;
      switch (_accessibilityLevel) {
        case 1: // Alta accesibilidad
          if (score < 4) return false;
          break;
        case 2: // Media accesibilidad
          if (score < 2 || score > 3) return false;
          break;
        case 3: // Baja accesibilidad
          if (score > 1) return false;
          break;
      }
    }

    // Verificar filtros de metadatos
    for (var entry in _metadataFilters.entries) {
      if (entry.value) { // Solo verificar los filtros que están activos
        final metadataValue = metadata[entry.key] as bool? ?? false;
        if (!metadataValue) {
          return false;
        }
      }
    }

    return true;
  }
} 