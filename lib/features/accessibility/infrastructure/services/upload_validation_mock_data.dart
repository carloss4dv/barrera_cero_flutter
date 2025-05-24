import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:result_dart/result_dart.dart';
import '../../domain/community_validation_model.dart';
import '../../domain/i_community_validation_service.dart';
import 'community_validation_service.dart';
import 'package:barrera_cero/features/users/services/user_service.dart';

class ValidationMockDataUploader {
  final FirebaseFirestore _firestore;
  final ICommunityValidationService _validationService;  ValidationMockDataUploader({
    FirebaseFirestore? firestore,
    ICommunityValidationService? validationService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _validationService = validationService ?? CommunityValidationService(FirebaseFirestore.instance, UserService());

  Future<void> uploadMockData() async {
    print('\n=== Iniciando subida de datos mock de validación a Firestore ===');
    
    // Lista de marcadores para los que crearemos validaciones
    final markerIds = [
      'marker_plaza_pilar',
      'marker_mercado_central',
      'marker_aljaferia',
      'marker_parque_grande',
      'marker_puente_piedra',
      'marker_estacion_delicias',
      'marker_el_tubo',
      'marker_grancasa',
      'marker_universidad',
      'marker_plaza_mayor',
      'marker_calle_principal',
      'marker_callejon',
      'marker_acuario',
    ];

    // Tipos de preguntas de validación
    final questionTypes = [
      ValidationQuestionType.rampExists,
      ValidationQuestionType.rampCondition,
      ValidationQuestionType.rampWidth,
      ValidationQuestionType.rampSlope,
      ValidationQuestionType.rampHandrails,
      ValidationQuestionType.rampLanding,
      ValidationQuestionType.rampObstacles,
      ValidationQuestionType.rampSurface,
      ValidationQuestionType.rampVisibility,
      ValidationQuestionType.rampMaintenance,
    ];

    // Crear validaciones para cada marcador y tipo de pregunta
    for (final markerId in markerIds) {
      for (final questionType in questionTypes) {
        final result = await _validationService.createValidation(markerId, questionType);
        result.fold(
          (validation) => print('Validación creada: ${validation.id}'),
          (error) => print('Error al crear validación: $error'),
        );
      }
    }

    print('=== Subida de datos mock de validación completada ===\n');
  }
} 