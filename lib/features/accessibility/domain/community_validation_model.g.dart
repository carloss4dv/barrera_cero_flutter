// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_validation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommunityValidationModel _$CommunityValidationModelFromJson(
  Map<String, dynamic> json,
) => _CommunityValidationModel(
  id: json['id'] as String,
  markerId: json['markerId'] as String,
  questionType: $enumDecode(
    _$ValidationQuestionTypeEnumMap,
    json['questionType'],
  ),
  positiveVotes: (json['positiveVotes'] as num).toInt(),
  negativeVotes: (json['negativeVotes'] as num).toInt(),
  totalVotesNeeded: (json['totalVotesNeeded'] as num).toInt(),
  status: $enumDecode(_$ValidationStatusEnumMap, json['status']),
  votedUserIds:
      (json['votedUserIds'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$CommunityValidationModelToJson(
  _CommunityValidationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'markerId': instance.markerId,
  'questionType': _$ValidationQuestionTypeEnumMap[instance.questionType]!,
  'positiveVotes': instance.positiveVotes,
  'negativeVotes': instance.negativeVotes,
  'totalVotesNeeded': instance.totalVotesNeeded,
  'status': _$ValidationStatusEnumMap[instance.status]!,
  'votedUserIds': instance.votedUserIds,
};

const _$ValidationQuestionTypeEnumMap = {
  ValidationQuestionType.rampExists: 'ramp_exists',
  ValidationQuestionType.rampCondition: 'ramp_condition',
  ValidationQuestionType.rampWidth: 'ramp_width',
  ValidationQuestionType.rampSlope: 'ramp_slope',
  ValidationQuestionType.rampHandrails: 'ramp_handrails',
  ValidationQuestionType.rampLanding: 'ramp_landing',
  ValidationQuestionType.rampObstacles: 'ramp_obstacles',
  ValidationQuestionType.rampSurface: 'ramp_surface',
  ValidationQuestionType.rampVisibility: 'ramp_visibility',
  ValidationQuestionType.rampMaintenance: 'ramp_maintenance',
};

const _$ValidationStatusEnumMap = {
  ValidationStatus.pending: 'pending',
  ValidationStatus.validated: 'validated',
  ValidationStatus.rejected: 'rejected',
};
