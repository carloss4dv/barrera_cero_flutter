// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marker_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarkerMetadata {

 bool get hasRamp; bool get hasElevator; bool get hasAccessibleBathroom; bool get hasBrailleSignage; bool get hasAudioGuidance; bool get hasTactilePavement; String get additionalNotes; int get accessibilityScore;
/// Create a copy of MarkerMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkerMetadataCopyWith<MarkerMetadata> get copyWith => _$MarkerMetadataCopyWithImpl<MarkerMetadata>(this as MarkerMetadata, _$identity);

  /// Serializes this MarkerMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkerMetadata&&(identical(other.hasRamp, hasRamp) || other.hasRamp == hasRamp)&&(identical(other.hasElevator, hasElevator) || other.hasElevator == hasElevator)&&(identical(other.hasAccessibleBathroom, hasAccessibleBathroom) || other.hasAccessibleBathroom == hasAccessibleBathroom)&&(identical(other.hasBrailleSignage, hasBrailleSignage) || other.hasBrailleSignage == hasBrailleSignage)&&(identical(other.hasAudioGuidance, hasAudioGuidance) || other.hasAudioGuidance == hasAudioGuidance)&&(identical(other.hasTactilePavement, hasTactilePavement) || other.hasTactilePavement == hasTactilePavement)&&(identical(other.additionalNotes, additionalNotes) || other.additionalNotes == additionalNotes)&&(identical(other.accessibilityScore, accessibilityScore) || other.accessibilityScore == accessibilityScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hasRamp,hasElevator,hasAccessibleBathroom,hasBrailleSignage,hasAudioGuidance,hasTactilePavement,additionalNotes,accessibilityScore);

@override
String toString() {
  return 'MarkerMetadata(hasRamp: $hasRamp, hasElevator: $hasElevator, hasAccessibleBathroom: $hasAccessibleBathroom, hasBrailleSignage: $hasBrailleSignage, hasAudioGuidance: $hasAudioGuidance, hasTactilePavement: $hasTactilePavement, additionalNotes: $additionalNotes, accessibilityScore: $accessibilityScore)';
}


}

/// @nodoc
abstract mixin class $MarkerMetadataCopyWith<$Res>  {
  factory $MarkerMetadataCopyWith(MarkerMetadata value, $Res Function(MarkerMetadata) _then) = _$MarkerMetadataCopyWithImpl;
@useResult
$Res call({
 bool hasRamp, bool hasElevator, bool hasAccessibleBathroom, bool hasBrailleSignage, bool hasAudioGuidance, bool hasTactilePavement, String additionalNotes, int accessibilityScore
});




}
/// @nodoc
class _$MarkerMetadataCopyWithImpl<$Res>
    implements $MarkerMetadataCopyWith<$Res> {
  _$MarkerMetadataCopyWithImpl(this._self, this._then);

  final MarkerMetadata _self;
  final $Res Function(MarkerMetadata) _then;

/// Create a copy of MarkerMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasRamp = null,Object? hasElevator = null,Object? hasAccessibleBathroom = null,Object? hasBrailleSignage = null,Object? hasAudioGuidance = null,Object? hasTactilePavement = null,Object? additionalNotes = null,Object? accessibilityScore = null,}) {
  return _then(_self.copyWith(
hasRamp: null == hasRamp ? _self.hasRamp : hasRamp // ignore: cast_nullable_to_non_nullable
as bool,hasElevator: null == hasElevator ? _self.hasElevator : hasElevator // ignore: cast_nullable_to_non_nullable
as bool,hasAccessibleBathroom: null == hasAccessibleBathroom ? _self.hasAccessibleBathroom : hasAccessibleBathroom // ignore: cast_nullable_to_non_nullable
as bool,hasBrailleSignage: null == hasBrailleSignage ? _self.hasBrailleSignage : hasBrailleSignage // ignore: cast_nullable_to_non_nullable
as bool,hasAudioGuidance: null == hasAudioGuidance ? _self.hasAudioGuidance : hasAudioGuidance // ignore: cast_nullable_to_non_nullable
as bool,hasTactilePavement: null == hasTactilePavement ? _self.hasTactilePavement : hasTactilePavement // ignore: cast_nullable_to_non_nullable
as bool,additionalNotes: null == additionalNotes ? _self.additionalNotes : additionalNotes // ignore: cast_nullable_to_non_nullable
as String,accessibilityScore: null == accessibilityScore ? _self.accessibilityScore : accessibilityScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _MarkerMetadata implements MarkerMetadata {
  const _MarkerMetadata({this.hasRamp = false, this.hasElevator = false, this.hasAccessibleBathroom = false, this.hasBrailleSignage = false, this.hasAudioGuidance = false, this.hasTactilePavement = false, this.additionalNotes = '', this.accessibilityScore = 0});
  factory _MarkerMetadata.fromJson(Map<String, dynamic> json) => _$MarkerMetadataFromJson(json);

@override@JsonKey() final  bool hasRamp;
@override@JsonKey() final  bool hasElevator;
@override@JsonKey() final  bool hasAccessibleBathroom;
@override@JsonKey() final  bool hasBrailleSignage;
@override@JsonKey() final  bool hasAudioGuidance;
@override@JsonKey() final  bool hasTactilePavement;
@override@JsonKey() final  String additionalNotes;
@override@JsonKey() final  int accessibilityScore;

/// Create a copy of MarkerMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkerMetadataCopyWith<_MarkerMetadata> get copyWith => __$MarkerMetadataCopyWithImpl<_MarkerMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarkerMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkerMetadata&&(identical(other.hasRamp, hasRamp) || other.hasRamp == hasRamp)&&(identical(other.hasElevator, hasElevator) || other.hasElevator == hasElevator)&&(identical(other.hasAccessibleBathroom, hasAccessibleBathroom) || other.hasAccessibleBathroom == hasAccessibleBathroom)&&(identical(other.hasBrailleSignage, hasBrailleSignage) || other.hasBrailleSignage == hasBrailleSignage)&&(identical(other.hasAudioGuidance, hasAudioGuidance) || other.hasAudioGuidance == hasAudioGuidance)&&(identical(other.hasTactilePavement, hasTactilePavement) || other.hasTactilePavement == hasTactilePavement)&&(identical(other.additionalNotes, additionalNotes) || other.additionalNotes == additionalNotes)&&(identical(other.accessibilityScore, accessibilityScore) || other.accessibilityScore == accessibilityScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hasRamp,hasElevator,hasAccessibleBathroom,hasBrailleSignage,hasAudioGuidance,hasTactilePavement,additionalNotes,accessibilityScore);

@override
String toString() {
  return 'MarkerMetadata(hasRamp: $hasRamp, hasElevator: $hasElevator, hasAccessibleBathroom: $hasAccessibleBathroom, hasBrailleSignage: $hasBrailleSignage, hasAudioGuidance: $hasAudioGuidance, hasTactilePavement: $hasTactilePavement, additionalNotes: $additionalNotes, accessibilityScore: $accessibilityScore)';
}


}

/// @nodoc
abstract mixin class _$MarkerMetadataCopyWith<$Res> implements $MarkerMetadataCopyWith<$Res> {
  factory _$MarkerMetadataCopyWith(_MarkerMetadata value, $Res Function(_MarkerMetadata) _then) = __$MarkerMetadataCopyWithImpl;
@override @useResult
$Res call({
 bool hasRamp, bool hasElevator, bool hasAccessibleBathroom, bool hasBrailleSignage, bool hasAudioGuidance, bool hasTactilePavement, String additionalNotes, int accessibilityScore
});




}
/// @nodoc
class __$MarkerMetadataCopyWithImpl<$Res>
    implements _$MarkerMetadataCopyWith<$Res> {
  __$MarkerMetadataCopyWithImpl(this._self, this._then);

  final _MarkerMetadata _self;
  final $Res Function(_MarkerMetadata) _then;

/// Create a copy of MarkerMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasRamp = null,Object? hasElevator = null,Object? hasAccessibleBathroom = null,Object? hasBrailleSignage = null,Object? hasAudioGuidance = null,Object? hasTactilePavement = null,Object? additionalNotes = null,Object? accessibilityScore = null,}) {
  return _then(_MarkerMetadata(
hasRamp: null == hasRamp ? _self.hasRamp : hasRamp // ignore: cast_nullable_to_non_nullable
as bool,hasElevator: null == hasElevator ? _self.hasElevator : hasElevator // ignore: cast_nullable_to_non_nullable
as bool,hasAccessibleBathroom: null == hasAccessibleBathroom ? _self.hasAccessibleBathroom : hasAccessibleBathroom // ignore: cast_nullable_to_non_nullable
as bool,hasBrailleSignage: null == hasBrailleSignage ? _self.hasBrailleSignage : hasBrailleSignage // ignore: cast_nullable_to_non_nullable
as bool,hasAudioGuidance: null == hasAudioGuidance ? _self.hasAudioGuidance : hasAudioGuidance // ignore: cast_nullable_to_non_nullable
as bool,hasTactilePavement: null == hasTactilePavement ? _self.hasTactilePavement : hasTactilePavement // ignore: cast_nullable_to_non_nullable
as bool,additionalNotes: null == additionalNotes ? _self.additionalNotes : additionalNotes // ignore: cast_nullable_to_non_nullable
as String,accessibilityScore: null == accessibilityScore ? _self.accessibilityScore : accessibilityScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
