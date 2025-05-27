import 'package:result_dart/result_dart.dart';
import 'package:barrera_cero/features/accessibility/domain/community_validation_model.dart';
import 'package:barrera_cero/features/accessibility/domain/i_community_validation_service.dart';

class MockCommunityValidationService implements ICommunityValidationService {
  final Map<String, List<CommunityValidationModel>> _mockData = {
    'marker1': [
      CommunityValidationModel(
        id: '1',
        markerId: 'marker1',
        questionType: ValidationQuestionType.rampExists,
        positiveVotes: 8,
        negativeVotes: 2,
        totalVotesNeeded: 10,
        status: ValidationStatus.validated,
        votedUserIds: ['user1', 'user2', 'user3', 'user4', 'user5', 'user6', 'user7', 'user8', 'user9', 'user10'],
      ),      CommunityValidationModel(
        id: '2',
        markerId: 'marker1',
        questionType: ValidationQuestionType.brailleSignageExists,
        positiveVotes: 5,
        negativeVotes: 2,
        totalVotesNeeded: 10,
        status: ValidationStatus.pending,
        votedUserIds: ['user1', 'user2', 'user3', 'user4', 'user5', 'user6', 'user7'],
      ),
      CommunityValidationModel(
        id: '3',
        markerId: 'marker1',
        questionType: ValidationQuestionType.elevatorExists,
        positiveVotes: 6,
        negativeVotes: 1,
        totalVotesNeeded: 10,
        status: ValidationStatus.pending,
        votedUserIds: ['user1', 'user2', 'user3', 'user4', 'user5', 'user6', 'user7'],
      ),
      CommunityValidationModel(
        id: '4',
        markerId: 'marker1',
        questionType: ValidationQuestionType.accessibleBathroomExists,
        positiveVotes: 4,
        negativeVotes: 3,
        totalVotesNeeded: 10,
        status: ValidationStatus.pending,
        votedUserIds: ['user1', 'user2', 'user3'],
      ),
    ],
  };

  @override
  Future<ResultDart<List<CommunityValidationModel>, Exception>> getValidationsForMarker(String markerId) async {
    try {
      final validations = _mockData[markerId] ?? [];
      return Success(validations);
    } catch (e) {
      return Failure(Exception('Error al obtener validaciones: $e'));
    }
  }

  @override
  Future<ResultDart<CommunityValidationModel, Exception>> addVote(
    String markerId,
    ValidationQuestionType questionType,
    bool isPositive,
    String userId,
  ) async {
    try {
      final validations = _mockData[markerId] ?? [];
      final validation = validations.firstWhere(
        (v) => v.questionType == questionType,
        orElse: () => throw Exception('Validación no encontrada'),
      );

      if (validation.votedUserIds.contains(userId)) {
        return Failure(Exception('Usuario ya ha votado'));
      }

      final updatedValidation = validation.copyWith(
        positiveVotes: isPositive ? validation.positiveVotes + 1 : validation.positiveVotes,
        negativeVotes: !isPositive ? validation.negativeVotes + 1 : validation.negativeVotes,
        votedUserIds: [...validation.votedUserIds, userId],
        status: _calculateNewStatus(
          validation.positiveVotes + (isPositive ? 1 : 0),
          validation.negativeVotes + (!isPositive ? 1 : 0),
          validation.totalVotesNeeded,
        ),
      );

      final index = validations.indexWhere((v) => v.questionType == questionType);
      validations[index] = updatedValidation;
      _mockData[markerId] = validations;

      return Success(updatedValidation);
    } catch (e) {
      return Failure(Exception('Error al agregar voto: $e'));
    }
  }

  @override
  Future<ResultDart<CommunityValidationModel, Exception>> createValidation(
    String markerId,
    ValidationQuestionType questionType,
  ) async {
    try {
      final validations = _mockData[markerId] ?? [];
      
      if (validations.any((v) => v.questionType == questionType)) {
        return Failure(Exception('Ya existe una validación para este tipo de pregunta'));
      }

      final newValidation = CommunityValidationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        markerId: markerId,
        questionType: questionType,
        positiveVotes: 0,
        negativeVotes: 0,
        totalVotesNeeded: 10,
        status: ValidationStatus.pending,
        votedUserIds: [],
      );

      validations.add(newValidation);
      _mockData[markerId] = validations;

      return Success(newValidation);
    } catch (e) {
      return Failure(Exception('Error al crear validación: $e'));
    }
  }
  ValidationStatus _calculateNewStatus(int positiveVotes, int negativeVotes, int totalNeeded) {
    // Calcular basado en la diferencia entre votos positivos y negativos
    final voteDifference = positiveVotes - negativeVotes;
    
    if (voteDifference >= totalNeeded) {
      return ValidationStatus.validated;
    } else if (voteDifference <= -totalNeeded) {
      return ValidationStatus.rejected;
    } else {
      return ValidationStatus.pending;
    }
  }
} 