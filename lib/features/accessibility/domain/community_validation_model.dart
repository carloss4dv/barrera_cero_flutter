import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_validation_model.freezed.dart';
part 'community_validation_model.g.dart';

/// Enum que representa los tipos de preguntas de validación
enum ValidationQuestionType {
  // Preguntas sobre existencia de elementos de accesibilidad
  @JsonValue('ramp_exists')
  rampExists,
  @JsonValue('elevator_exists')
  elevatorExists,
  @JsonValue('accessible_bathroom_exists')
  accessibleBathroomExists,
  @JsonValue('braille_signage_exists')
  brailleSignageExists,
  @JsonValue('audio_guidance_exists')
  audioGuidanceExists,
  @JsonValue('tactile_pavement_exists')
  tactilePavementExists,
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
    // Calculando el progreso basado en la diferencia entre votos positivos y negativos
    final voteDifference = positiveVotes - negativeVotes;
    return voteDifference / totalVotesNeeded;
  }  String getQuestionText() {
    switch (questionType) {
      // Preguntas sobre existencia de elementos de accesibilidad
      case ValidationQuestionType.rampExists:
        return '¿Existe una rampa en este lugar?';
      case ValidationQuestionType.elevatorExists:
        return '¿Existe un ascensor en este lugar?';
      case ValidationQuestionType.accessibleBathroomExists:
        return '¿Existe un baño accesible en este lugar?';
      case ValidationQuestionType.brailleSignageExists:
        return '¿Existe señalización en Braille en este lugar?';      
      case ValidationQuestionType.audioGuidanceExists:
        return '¿Existe guía de audio en este lugar?';
      case ValidationQuestionType.tactilePavementExists:
        return '¿Existe pavimento táctil en este lugar?';
    }
  }
}

/// Extensión para ValidationQuestionType
extension ValidationQuestionTypeExtension on ValidationQuestionType {
  String getQuestionText() {
    switch (this) {
      // Preguntas sobre existencia de elementos de accesibilidad
      case ValidationQuestionType.rampExists:
        return '¿Existe una rampa en este lugar?';
      case ValidationQuestionType.elevatorExists:
        return '¿Existe un ascensor en este lugar?';
      case ValidationQuestionType.accessibleBathroomExists:
        return '¿Existe un baño accesible en este lugar?';
      case ValidationQuestionType.brailleSignageExists:
        return '¿Existe señalización en Braille en este lugar?';
      case ValidationQuestionType.audioGuidanceExists:
        return '¿Existe guía de audio en este lugar?';
      case ValidationQuestionType.tactilePavementExists:
        return '¿Existe pavimento táctil en este lugar?';
    }
  }
}