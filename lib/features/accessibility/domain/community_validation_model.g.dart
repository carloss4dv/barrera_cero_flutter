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
      (json['votedUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
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
  ValidationQuestionType.ramps: 'ramps',
  ValidationQuestionType.adaptedBathrooms: 'adaptedBathrooms',
  ValidationQuestionType.accessibleElevators: 'accessibleElevators',
  ValidationQuestionType.tactileSignage: 'tactileSignage',
};

const _$ValidationStatusEnumMap = {
  ValidationStatus.pending: 'pending',
  ValidationStatus.verified: 'verified',
  ValidationStatus.refuted: 'refuted',
};
