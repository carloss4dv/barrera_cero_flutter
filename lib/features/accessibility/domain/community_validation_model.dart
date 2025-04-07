import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_validation_model.freezed.dart';
part 'community_validation_model.g.dart';

enum ValidationQuestionType {
  ramps,
  adaptedBathrooms,
  accessibleElevators,
  tactileSignage
}

enum ValidationStatus {
  pending,
  verified,
  refuted
}

@freezed
class CommunityValidationModel with _$CommunityValidationModel {
  const factory CommunityValidationModel({
    required String id,
    required String markerId,
    required ValidationQuestionType questionType,
    required int positiveVotes,
    required int negativeVotes,
    required int totalVotesNeeded,
    required ValidationStatus status,
    @Default([]) List<String> votedUserIds,
  }) = _CommunityValidationModel;

  factory CommunityValidationModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityValidationModelFromJson(json);
}

extension CommunityValidationModelX on CommunityValidationModel {
  bool get isVerified => status == ValidationStatus.verified;
  bool get isRefuted => status == ValidationStatus.refuted;
  bool get isPending => status == ValidationStatus.pending;
  
  double get progress => (positiveVotes + negativeVotes) / totalVotesNeeded;
  
  String get questionText {
    switch (questionType) {
      case ValidationQuestionType.ramps:
        return '¿Hay rampas de acceso?';
      case ValidationQuestionType.adaptedBathrooms:
        return '¿Hay baños adaptados?';
      case ValidationQuestionType.accessibleElevators:
        return '¿Hay ascensores accesibles?';
      case ValidationQuestionType.tactileSignage:
        return '¿Hay señalización táctil?';
    }
  }
} 