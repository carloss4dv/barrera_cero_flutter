import 'package:result_dart/result_dart.dart';
import 'package:barrera_cero/features/accessibility/domain/community_validation_model.dart';

abstract class ICommunityValidationService {
  Future<Result<List<CommunityValidationModel>>> getValidationsForMarker(String markerId);
  Future<Result<CommunityValidationModel>> addVote(
    String markerId,
    ValidationQuestionType questionType,
    bool isPositive,
    String userId,
  );
  Future<Result<CommunityValidationModel>> createValidation(
    String markerId,
    ValidationQuestionType questionType,
  );
} 