// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_validation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommunityValidationModel {

 String get id; String get markerId; ValidationQuestionType get questionType; int get positiveVotes; int get negativeVotes; int get totalVotesNeeded; ValidationStatus get status; List<String> get votedUserIds;
/// Create a copy of CommunityValidationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityValidationModelCopyWith<CommunityValidationModel> get copyWith => _$CommunityValidationModelCopyWithImpl<CommunityValidationModel>(this as CommunityValidationModel, _$identity);

  /// Serializes this CommunityValidationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityValidationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.markerId, markerId) || other.markerId == markerId)&&(identical(other.questionType, questionType) || other.questionType == questionType)&&(identical(other.positiveVotes, positiveVotes) || other.positiveVotes == positiveVotes)&&(identical(other.negativeVotes, negativeVotes) || other.negativeVotes == negativeVotes)&&(identical(other.totalVotesNeeded, totalVotesNeeded) || other.totalVotesNeeded == totalVotesNeeded)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.votedUserIds, votedUserIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,markerId,questionType,positiveVotes,negativeVotes,totalVotesNeeded,status,const DeepCollectionEquality().hash(votedUserIds));

@override
String toString() {
  return 'CommunityValidationModel(id: $id, markerId: $markerId, questionType: $questionType, positiveVotes: $positiveVotes, negativeVotes: $negativeVotes, totalVotesNeeded: $totalVotesNeeded, status: $status, votedUserIds: $votedUserIds)';
}


}

/// @nodoc
abstract mixin class $CommunityValidationModelCopyWith<$Res>  {
  factory $CommunityValidationModelCopyWith(CommunityValidationModel value, $Res Function(CommunityValidationModel) _then) = _$CommunityValidationModelCopyWithImpl;
@useResult
$Res call({
 String id, String markerId, ValidationQuestionType questionType, int positiveVotes, int negativeVotes, int totalVotesNeeded, ValidationStatus status, List<String> votedUserIds
});




}
/// @nodoc
class _$CommunityValidationModelCopyWithImpl<$Res>
    implements $CommunityValidationModelCopyWith<$Res> {
  _$CommunityValidationModelCopyWithImpl(this._self, this._then);

  final CommunityValidationModel _self;
  final $Res Function(CommunityValidationModel) _then;

/// Create a copy of CommunityValidationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? markerId = null,Object? questionType = null,Object? positiveVotes = null,Object? negativeVotes = null,Object? totalVotesNeeded = null,Object? status = null,Object? votedUserIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,markerId: null == markerId ? _self.markerId : markerId // ignore: cast_nullable_to_non_nullable
as String,questionType: null == questionType ? _self.questionType : questionType // ignore: cast_nullable_to_non_nullable
as ValidationQuestionType,positiveVotes: null == positiveVotes ? _self.positiveVotes : positiveVotes // ignore: cast_nullable_to_non_nullable
as int,negativeVotes: null == negativeVotes ? _self.negativeVotes : negativeVotes // ignore: cast_nullable_to_non_nullable
as int,totalVotesNeeded: null == totalVotesNeeded ? _self.totalVotesNeeded : totalVotesNeeded // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ValidationStatus,votedUserIds: null == votedUserIds ? _self.votedUserIds : votedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _CommunityValidationModel implements CommunityValidationModel {
  const _CommunityValidationModel({required this.id, required this.markerId, required this.questionType, required this.positiveVotes, required this.negativeVotes, required this.totalVotesNeeded, required this.status, final  List<String> votedUserIds = const []}): _votedUserIds = votedUserIds;
  factory _CommunityValidationModel.fromJson(Map<String, dynamic> json) => _$CommunityValidationModelFromJson(json);

@override final  String id;
@override final  String markerId;
@override final  ValidationQuestionType questionType;
@override final  int positiveVotes;
@override final  int negativeVotes;
@override final  int totalVotesNeeded;
@override final  ValidationStatus status;
 final  List<String> _votedUserIds;
@override@JsonKey() List<String> get votedUserIds {
  if (_votedUserIds is EqualUnmodifiableListView) return _votedUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_votedUserIds);
}


/// Create a copy of CommunityValidationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityValidationModelCopyWith<_CommunityValidationModel> get copyWith => __$CommunityValidationModelCopyWithImpl<_CommunityValidationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityValidationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityValidationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.markerId, markerId) || other.markerId == markerId)&&(identical(other.questionType, questionType) || other.questionType == questionType)&&(identical(other.positiveVotes, positiveVotes) || other.positiveVotes == positiveVotes)&&(identical(other.negativeVotes, negativeVotes) || other.negativeVotes == negativeVotes)&&(identical(other.totalVotesNeeded, totalVotesNeeded) || other.totalVotesNeeded == totalVotesNeeded)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._votedUserIds, _votedUserIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,markerId,questionType,positiveVotes,negativeVotes,totalVotesNeeded,status,const DeepCollectionEquality().hash(_votedUserIds));

@override
String toString() {
  return 'CommunityValidationModel(id: $id, markerId: $markerId, questionType: $questionType, positiveVotes: $positiveVotes, negativeVotes: $negativeVotes, totalVotesNeeded: $totalVotesNeeded, status: $status, votedUserIds: $votedUserIds)';
}


}

/// @nodoc
abstract mixin class _$CommunityValidationModelCopyWith<$Res> implements $CommunityValidationModelCopyWith<$Res> {
  factory _$CommunityValidationModelCopyWith(_CommunityValidationModel value, $Res Function(_CommunityValidationModel) _then) = __$CommunityValidationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String markerId, ValidationQuestionType questionType, int positiveVotes, int negativeVotes, int totalVotesNeeded, ValidationStatus status, List<String> votedUserIds
});




}
/// @nodoc
class __$CommunityValidationModelCopyWithImpl<$Res>
    implements _$CommunityValidationModelCopyWith<$Res> {
  __$CommunityValidationModelCopyWithImpl(this._self, this._then);

  final _CommunityValidationModel _self;
  final $Res Function(_CommunityValidationModel) _then;

/// Create a copy of CommunityValidationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? markerId = null,Object? questionType = null,Object? positiveVotes = null,Object? negativeVotes = null,Object? totalVotesNeeded = null,Object? status = null,Object? votedUserIds = null,}) {
  return _then(_CommunityValidationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,markerId: null == markerId ? _self.markerId : markerId // ignore: cast_nullable_to_non_nullable
as String,questionType: null == questionType ? _self.questionType : questionType // ignore: cast_nullable_to_non_nullable
as ValidationQuestionType,positiveVotes: null == positiveVotes ? _self.positiveVotes : positiveVotes // ignore: cast_nullable_to_non_nullable
as int,negativeVotes: null == negativeVotes ? _self.negativeVotes : negativeVotes // ignore: cast_nullable_to_non_nullable
as int,totalVotesNeeded: null == totalVotesNeeded ? _self.totalVotesNeeded : totalVotesNeeded // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ValidationStatus,votedUserIds: null == votedUserIds ? _self._votedUserIds : votedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
