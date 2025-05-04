import 'package:freezed_annotation/freezed_annotation.dart';
import 'accessibility_report_model.dart';

part 'community_validation_model.freezed.dart';
part 'community_validation_model.g.dart';

/// Enum que representa los tipos de preguntas de validación
enum ValidationQuestionType {
  @JsonValue('ramp_exists')
  rampExists,
  @JsonValue('ramp_condition')
  rampCondition,
  @JsonValue('ramp_width')
  rampWidth,
  @JsonValue('ramp_slope')
  rampSlope,
  @JsonValue('ramp_handrails')
  rampHandrails,
  @JsonValue('ramp_landing')
  rampLanding,
  @JsonValue('ramp_obstacles')
  rampObstacles,
  @JsonValue('ramp_surface')
  rampSurface,
  @JsonValue('ramp_visibility')
  rampVisibility,
  @JsonValue('ramp_maintenance')
  rampMaintenance,
  @JsonValue('stairs_exist')
  stairsExist,
  @JsonValue('slope')
  slope,
  @JsonValue('surface_type')
  surfaceType,
}

/// Enum que representa el estado de una validación
enum ValidationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('validated')
  validated,
}

@freezed
class CommunityValidationModel with _$CommunityValidationModel {
  const CommunityValidationModel._();

  const factory CommunityValidationModel({
    required String id,
    required String markerId,
    required ValidationQuestionType questionType,
    required int positiveVotes,
    required int negativeVotes,
    required int totalVotesNeeded,
    required ValidationStatus status,
    required List<String> votedUserIds,
  }) = _CommunityValidationModel;

  factory CommunityValidationModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityValidationModelFromJson(json);

  @override
  String get id => (this as _CommunityValidationModel).id;

  @override
  String get markerId => (this as _CommunityValidationModel).markerId;

  @override
  ValidationQuestionType get questionType => (this as _CommunityValidationModel).questionType;

  @override
  int get positiveVotes => (this as _CommunityValidationModel).positiveVotes;

  @override
  int get negativeVotes => (this as _CommunityValidationModel).negativeVotes;

  @override
  int get totalVotesNeeded => (this as _CommunityValidationModel).totalVotesNeeded;

  @override
  ValidationStatus get status => (this as _CommunityValidationModel).status;

  @override
  List<String> get votedUserIds => (this as _CommunityValidationModel).votedUserIds;

  @override
  Map<String, dynamic> toJson() => _$CommunityValidationModelToJson(this as _CommunityValidationModel);

  bool isPending() => status == ValidationStatus.pending;
  bool isValidated() => status == ValidationStatus.approved;
  bool isRejected() => status == ValidationStatus.rejected;

  double getProgress() {
    final totalVotes = positiveVotes + negativeVotes;
    return totalVotes / totalVotesNeeded;
  }

  String getQuestionText() {
    switch (questionType) {
      case ValidationQuestionType.rampExists:
        return '¿Existe una rampa en este lugar?';
      case ValidationQuestionType.rampCondition:
        return '¿En qué estado se encuentra la rampa?';
      case ValidationQuestionType.rampWidth:
        return '¿La rampa tiene el ancho adecuado?';
      case ValidationQuestionType.rampSlope:
        return '¿La pendiente de la rampa es adecuada?';
      case ValidationQuestionType.rampHandrails:
        return '¿La rampa tiene pasamanos?';
      case ValidationQuestionType.rampLanding:
        return '¿La rampa tiene plataforma de descanso?';
      case ValidationQuestionType.rampObstacles:
        return '¿Hay obstáculos en la rampa?';
      case ValidationQuestionType.rampSurface:
        return '¿La superficie de la rampa es adecuada?';
      case ValidationQuestionType.rampVisibility:
        return '¿La rampa es visible y accesible?';
      case ValidationQuestionType.rampMaintenance:
        return '¿La rampa está bien mantenida?';
      case ValidationQuestionType.stairsExist:
        return '¿Existe una escalera en este lugar?';
      case ValidationQuestionType.slope:
        return '¿La pendiente de la rampa es adecuada?';
      case ValidationQuestionType.surfaceType:
        return '¿El tipo de superficie de la rampa es adecuado?';
    }
  }
} 