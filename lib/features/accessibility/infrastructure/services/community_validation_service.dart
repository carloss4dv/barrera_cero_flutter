import 'package:result_dart/result_dart.dart';
import 'package:barrera_cero/features/accessibility/domain/community_validation_model.dart';
import 'package:barrera_cero/features/accessibility/domain/i_community_validation_service.dart';
import 'package:barrera_cero/features/users/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityValidationService implements ICommunityValidationService {
  final FirebaseFirestore _firestore;
  final UserService _userService;
  static const int _defaultVotesNeeded = 10;

  CommunityValidationService(this._firestore, this._userService);

  @override
  Future<Result<List<CommunityValidationModel>>> getValidationsForMarker(String markerId) async {
    try {
      final snapshot = await _firestore
          .collection('places')
          .doc(markerId)
          .collection('validations')
          .get();

      final validations = snapshot.docs.map((doc) {
        return CommunityValidationModel.fromJson(doc.data());
      }).toList();

      return Success(validations);
    } catch (e) {
      return Failure(Exception('Error al cargar validaciones: $e'));
    }
  }  @override
  Future<Result<CommunityValidationModel>> addVote(
    String markerId,
    ValidationQuestionType questionType,
    bool isPositive,
    String userId,
  ) async {
    try {
      final validationRef = _firestore
          .collection('places')
          .doc(markerId)
          .collection('validations')
          .doc(questionType.toString());

      final transactionResult = await _firestore.runTransaction<Result<CommunityValidationModel>>((transaction) async {
        final doc = await transaction.get(validationRef);
        CommunityValidationModel validation;

        if (!doc.exists) {
          validation = CommunityValidationModel(
            id: questionType.toString(),
            markerId: markerId,
            questionType: questionType,
            positiveVotes: isPositive ? 1 : 0,
            negativeVotes: isPositive ? 0 : 1,
            totalVotesNeeded: _defaultVotesNeeded,
            status: ValidationStatus.pending,
            votedUserIds: [userId],
          );
        } else {
          validation = CommunityValidationModel.fromJson(doc.data()!);
          
          if (validation.votedUserIds.contains(userId)) {
            return Failure(Exception('Ya has votado en esta validación'));
          }

          validation = validation.copyWith(
            positiveVotes: isPositive ? validation.positiveVotes + 1 : validation.positiveVotes,
            negativeVotes: !isPositive ? validation.negativeVotes + 1 : validation.negativeVotes,
            votedUserIds: [...validation.votedUserIds, userId],
          );          // Actualizar estado basado en la diferencia entre votos positivos y negativos
          final voteDifference = validation.positiveVotes - validation.negativeVotes;
          if (voteDifference >= validation.totalVotesNeeded) {
            validation = validation.copyWith(status: ValidationStatus.approved);
          } else if (voteDifference <= -validation.totalVotesNeeded) {
            validation = validation.copyWith(status: ValidationStatus.rejected);
          } else {
            validation = validation.copyWith(status: ValidationStatus.pending);
          }
        }

        transaction.set(validationRef, validation.toJson());
        return Success(validation);
      });

      // Si la transacción fue exitosa, otorgar B-points al usuario
      return transactionResult.fold(
        (validation) async {
          try {
            await _userService.awardValidationPoints(userId);
            print('Se otorgaron ${UserService.VALIDATION_VOTE_POINTS} B-points al usuario $userId por votar en validación');
            return Success(validation);
          } catch (e) {
            print('Error al otorgar puntos al usuario $userId: $e');
            // Devolver éxito de la validación aunque haya fallado la otorgación de puntos
            return Success(validation);
          }
        },
        (error) => Failure(error),
      );
    } catch (e) {
      return Failure(Exception('Error al registrar voto: $e'));
    }
  }

  @override
  Future<Result<CommunityValidationModel>> createValidation(
    String markerId,
    ValidationQuestionType questionType,
  ) async {
    try {
      final validation = CommunityValidationModel(
        id: questionType.toString(),
        markerId: markerId,
        questionType: questionType,
        positiveVotes: 0,
        negativeVotes: 0,
        totalVotesNeeded: _defaultVotesNeeded,
        status: ValidationStatus.pending,
        votedUserIds: [],
      );

      await _firestore
          .collection('places')
          .doc(markerId)
          .collection('validations')
          .doc(questionType.toString())
          .set(validation.toJson());

      return Success(validation);
    } catch (e) {
      return Failure(Exception('Error al crear validación: $e'));
    }
  }
}