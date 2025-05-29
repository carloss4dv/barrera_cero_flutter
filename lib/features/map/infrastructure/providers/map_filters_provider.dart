import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../../accessibility/domain/i_accessibility_report_service.dart';
import '../../../accessibility/domain/accessibility_report_model.dart';
import '../../../accessibility/domain/i_community_validation_service.dart';
import '../../../accessibility/domain/community_validation_model.dart';

class MapFiltersProvider extends ChangeNotifier {
  late final IAccessibilityReportService _reportService;
  late final ICommunityValidationService _validationService;
  int _accessibilityLevel = 0;
  Map<String, bool> _metadataFilters = {
    'hasRamp': false,
    'hasElevator': false,
    'hasAccessibleBathroom': false,
    'hasBrailleSignage': false,
    'hasAudioGuidance': false,
    'hasTactilePavement': false,
  };

  // Umbral de diferencia de votos para considerar una validación como positiva
  static const int _voteThreshold = 10;

  MapFiltersProvider() {
    _reportService = GetIt.instance<IAccessibilityReportService>();
    _validationService = GetIt.instance<ICommunityValidationService>();
  }

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
    print('\n=== Verificando filtros para marcador ===');
    print('Metadatos: $metadata');
    print('Nivel de accesibilidad: $_accessibilityLevel');
    print('Filtros activos: $_metadataFilters');

    // Si es el marcador de ubicación actual, siempre mostrarlo
    if (metadata['type'] == 'currentLocation') {
      print('Es marcador de ubicación actual - Mostrando');
      return true;
    }

    // Si no hay filtros activos, mostrar todos los marcadores
    if (_accessibilityLevel == 0 && !_metadataFilters.values.any((value) => value)) {
      print('No hay filtros activos - Mostrando');
      return true;
    }

    // Si hay filtros de metadatos activos, usar fallback a metadatos para compatibilidad
    // El método asíncrono shouldShowMarkerAsync proporcionará el filtrado real basado en validaciones
    for (var entry in _metadataFilters.entries) {
      if (entry.value) { // Solo verificar los filtros que están activos
        final metadataValue = metadata[entry.key] as bool? ?? false;
        print('Verificando filtro ${entry.key}: valor=${metadataValue}, requerido=${entry.value}');
        if (!metadataValue) {
          print('No cumple con el filtro ${entry.key} (fallback a metadata) - Ocultando');
          return false;
        }
      }
    }

    // Si no hay filtro de accesibilidad activo, mostrar el marcador
    if (_accessibilityLevel == 0) {
      print('No hay filtro de accesibilidad activo - Mostrando');
      return true;
    }

    // Para filtros de accesibilidad, usar el metadata score como fallback para compatibilidad
    // Este será actualizado por el método asíncrono cuando sea posible
    final double score = (metadata['accessibilityScore'] ?? 0.0).toDouble();
    print('Puntuación de accesibilidad (metadata): $score');
    
    switch (_accessibilityLevel) {
      case 1: // Alta accesibilidad (4.0 - 5.0)
        if (score >= 4.0) {
          print('Cumple con alta accesibilidad - Mostrando');
          return true;
        } else {
          print('No cumple con alta accesibilidad - Ocultando');
          return false;
        }
      case 2: // Media accesibilidad (2.0 - 3.99)
        if (score >= 2.0 && score < 4.0) {
          print('Cumple con media accesibilidad - Mostrando');
          return true;
        } else {
          print('No cumple con media accesibilidad - Ocultando');
          return false;
        }
      case 3: // Baja accesibilidad (1.0 - 1.99)
        if (score >= 1.0 && score < 2.0) {
          print('Cumple con baja accesibilidad - Mostrando');
          return true;
        } else {
          print('No cumple con baja accesibilidad - Ocultando');
          return false;
        }
      default:
        return true;
    }
  }  /// Verifica de forma asíncrona si un marcador debe mostrarse basado en los reportes y validaciones
  Future<bool> shouldShowMarkerAsync(Map<String, dynamic> metadata, String markerId) async {
    // Verificaciones síncronas primero
    if (metadata['type'] == 'currentLocation') {
      return true;
    }

    if (_accessibilityLevel == 0 && !_metadataFilters.values.any((value) => value)) {
      return true;
    }

    // Verificar filtros de metadatos basados en validaciones comunitarias
    for (var entry in _metadataFilters.entries) {
      if (entry.value) {
        final hasValidValidation = await _checkValidationForFilter(markerId, entry.key);
        if (!hasValidValidation) {
          return false;
        }
      }
    }

    // Si no hay filtro de accesibilidad activo, mostrar el marcador
    if (_accessibilityLevel == 0) {
      return true;
    }

    // Verificar nivel de accesibilidad basado en reportes
    try {
      final reportsResult = await _reportService.getReportsForMarker(markerId);
      return reportsResult.fold(
        (reports) {
          if (reports.isEmpty) {
            // Si no hay reportes, mostrar en "Todos" (nivel 0) pero no en otros filtros específicos
            return _accessibilityLevel == 0;
          }

          // Calcular puntuación promedio igual que en custom_map_marker.dart
          double totalScore = 0;
          for (final report in reports) {
            switch (report.level) {
              case AccessibilityLevel.good:
                totalScore += 5; // Reporte positivo vale 5
                break;
              case AccessibilityLevel.medium:
                totalScore += 3; // Reporte neutro vale 3
                break;
              case AccessibilityLevel.bad:
                totalScore += 1; // Reporte negativo vale 1
                break;
            }
          }
          
          final averageScore = totalScore / reports.length;
          print('Puntuación calculada desde reportes: $averageScore');

          switch (_accessibilityLevel) {
            case 1: // Alta accesibilidad (4.0 - 5.0)
              if (averageScore >= 4.0) {
                print('Cumple con alta accesibilidad - Mostrando');
                return true;
              } else {
                print('No cumple con alta accesibilidad - Ocultando');
                return false;
              }
            case 2: // Media accesibilidad (2.0 - 3.99)
              if (averageScore >= 2.0 && averageScore < 4.0) {
                print('Cumple con media accesibilidad - Mostrando');
                return true;
              } else {
                print('No cumple con media accesibilidad - Ocultando');
                return false;
              }
            case 3: // Baja accesibilidad (1.0 - 1.99)
              if (averageScore >= 1.0 && averageScore < 2.0) {
                print('Cumple con baja accesibilidad - Mostrando');
                return true;
              } else {
                print('No cumple con baja accesibilidad - Ocultando');
                return false;
              }
            default:
              return true;
          }
        },
        (failure) {
          print('Error al obtener reportes: $failure');
          // En caso de error, mostrar el marcador solo si no hay filtro específico activo
          return _accessibilityLevel == 0;
        },
      );
    } catch (e) {
      print('Error al verificar reportes: $e');
      // En caso de error, mostrar el marcador solo si no hay filtro específico activo
      return _accessibilityLevel == 0;
    }
  }

  /// Verifica si un marcador tiene validaciones positivas para un filtro específico
  Future<bool> _checkValidationForFilter(String markerId, String filterKey) async {
    try {
      print('Verificando validación para filtro $filterKey en marcador $markerId');
      
      final validationsResult = await _validationService.getValidationsForMarker(markerId);
      return validationsResult.fold(
        (validations) {
          ValidationQuestionType? targetType;

          // Mapear el filtro al tipo de validación correspondiente
          switch (filterKey) {
            case 'hasRamp':
              targetType = ValidationQuestionType.rampExists;
              break;
            case 'hasElevator':
              targetType = ValidationQuestionType.elevatorExists;
              break;
            case 'hasAccessibleBathroom':
              targetType = ValidationQuestionType.accessibleBathroomExists;
              break;
            case 'hasBrailleSignage':
              targetType = ValidationQuestionType.brailleSignageExists;
              break;
            case 'hasAudioGuidance':
              targetType = ValidationQuestionType.audioGuidanceExists;
              break;
            case 'hasTactilePavement':
              targetType = ValidationQuestionType.tactilePavementExists;
              break;
            default:
              return false;
          }

          // Buscar la validación específica
          final targetValidation = validations.firstWhere(
            (v) => v.questionType == targetType,
            orElse: () => CommunityValidationModel(
              id: '',
              markerId: markerId,
              questionType: targetType!,
              positiveVotes: 0,
              negativeVotes: 0,
              totalVotesNeeded: 10,
              status: ValidationStatus.pending,
              votedUserIds: [],
            ),
          );

          // Calcular la diferencia de votos
          final voteDifference = targetValidation.positiveVotes - targetValidation.negativeVotes;
          
          print('Validación $filterKey: +${targetValidation.positiveVotes} -${targetValidation.negativeVotes} = $voteDifference');
          
          // Retornar true si la diferencia es mayor al umbral
          final meetsThreshold = voteDifference > _voteThreshold;
          print('¿Cumple el umbral de $_voteThreshold votos? $meetsThreshold');
          
          return meetsThreshold;
        },
        (error) {
          print('Error al obtener validaciones: $error');
          return false;
        },
      );
      
    } catch (e) {
      print('Error al verificar validación para filtro $filterKey: $e');
      return false;
    }
  }
}