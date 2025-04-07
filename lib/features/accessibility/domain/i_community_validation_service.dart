import 'package:result_dart/result_dart.dart';
import 'package:barrera_cero/features/accessibility/domain/community_validation_model.dart';

abstract class ICommunityValidationService {
  Future<Result<List<CommunityValidationModel>, Exception>> getValidationsForMarker(String markerId);
  Future<Result<CommunityValidationModel, Exception>> addVote(
    String markerId,
    ValidationQuestionType questionType,
    bool isPositive,
    String userId,
  );
  Future<Result<CommunityValidationModel, Exception>> createValidation(
    String markerId,
    ValidationQuestionType questionType,
  );
} 