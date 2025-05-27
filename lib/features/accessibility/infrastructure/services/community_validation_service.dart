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

      final validations = <CommunityValidationModel>[];
      
      for (final doc in snapshot.docs) {
        try {
          final validation = CommunityValidationModel.fromJson(doc.data());
          validations.add(validation);
        } catch (e) {
          // Ignorar validaciones con tipos de pregunta no válidos (datos obsoletos)
          print('Ignorando validación con tipo no válido: ${doc.data()['questionType']} - Error: $e');
          
          // Opcionalmente eliminar el documento obsoleto
          try {
            await doc.reference.delete();
            print('Eliminado documento obsoleto: ${doc.id}');
          } catch (deleteError) {
            print('Error al eliminar documento obsoleto: $deleteError');
          }
        }
      }

      return Success(validations);
    } catch (e) {
      return Failure(Exception('Error al cargar validaciones: $e'));
    }
  }@override
  Future<Result<CommunityValidationModel>> addVote(
    String markerId,
    ValidationQuestionType questionType,
    bool isPositive,
    String userId,
  ) async {
    try {
      print('Adding vote: markerId=$markerId, questionType=$questionType, isPositive=$isPositive, userId=$userId');
      
      final validationRef = _firestore
          .collection('places')
          .doc(markerId)
          .collection('validations')
          .doc(questionType.toString());

      print('Validation ref path: ${validationRef.path}');

      final transactionResult = await _firestore.runTransaction<Result<CommunityValidationModel>>((transaction) async {
        final doc = await transaction.get(validationRef);
        CommunityValidationModel validation;

        if (!doc.exists) {
          print('Document does not exist, creating new validation');
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
      print('Creating validation: markerId=$markerId, questionType=$questionType');
      
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

      final docRef = _firestore
          .collection('places')
          .doc(markerId)
          .collection('validations')
          .doc(questionType.toString());

      print('Creating validation at path: ${docRef.path}');
      
      await docRef.set(validation.toJson());

      print('Successfully created validation: ${validation.id}');
      return Success(validation);
    } catch (e) {
      return Failure(Exception('Error al crear validación: $e'));
    }
  }

  /// Método para limpiar todas las validaciones obsoletas de Firebase
  /// Esto incluye validaciones con tipos de pregunta que ya no existen
  Future<void> cleanObsoleteValidations() async {
    try {
      print('Iniciando limpieza de validaciones obsoletas...');
      
      // Obtener todos los lugares
      final placesSnapshot = await _firestore.collection('places').get();
      
      int totalObsolete = 0;
      int totalCleaned = 0;
      
      for (final placeDoc in placesSnapshot.docs) {
        final validationsSnapshot = await placeDoc.reference.collection('validations').get();
        
        for (final validationDoc in validationsSnapshot.docs) {
          try {
            // Intentar deserializar la validación
            CommunityValidationModel.fromJson(validationDoc.data());
          } catch (e) {
            // Si falla la deserialización, es porque el tipo de pregunta no es válido
            totalObsolete++;
            print('Encontrada validación obsoleta en lugar ${placeDoc.id}: ${validationDoc.data()['questionType']}');
            
            try {
              await validationDoc.reference.delete();
              totalCleaned++;
              print('Eliminada validación obsoleta: ${validationDoc.id}');
            } catch (deleteError) {
              print('Error al eliminar validación obsoleta ${validationDoc.id}: $deleteError');
            }
          }
        }
      }
      
      print('Limpieza completada: $totalCleaned/$totalObsolete validaciones obsoletas eliminadas');
    } catch (e) {
      print('Error durante la limpieza de validaciones obsoletas: $e');
    }
  }
}