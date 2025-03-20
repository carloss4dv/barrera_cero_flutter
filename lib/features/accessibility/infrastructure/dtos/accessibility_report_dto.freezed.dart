// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accessibility_report_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccessibilityReportDto {

 String get id;@JsonKey(name: 'user_id') String get userId; String get comments;@JsonKey(name: 'accessibility_level') AccessibilityLevel get level;
/// Create a copy of AccessibilityReportDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccessibilityReportDtoCopyWith<AccessibilityReportDto> get copyWith => _$AccessibilityReportDtoCopyWithImpl<AccessibilityReportDto>(this as AccessibilityReportDto, _$identity);

  /// Serializes this AccessibilityReportDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccessibilityReportDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,comments,level);

@override
String toString() {
  return 'AccessibilityReportDto(id: $id, userId: $userId, comments: $comments, level: $level)';
}


}

/// @nodoc
abstract mixin class $AccessibilityReportDtoCopyWith<$Res>  {
  factory $AccessibilityReportDtoCopyWith(AccessibilityReportDto value, $Res Function(AccessibilityReportDto) _then) = _$AccessibilityReportDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String comments,@JsonKey(name: 'accessibility_level') AccessibilityLevel level
});




}
/// @nodoc
class _$AccessibilityReportDtoCopyWithImpl<$Res>
    implements $AccessibilityReportDtoCopyWith<$Res> {
  _$AccessibilityReportDtoCopyWithImpl(this._self, this._then);

  final AccessibilityReportDto _self;
  final $Res Function(AccessibilityReportDto) _then;

/// Create a copy of AccessibilityReportDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? comments = null,Object? level = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as AccessibilityLevel,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AccessibilityReportDto implements AccessibilityReportDto {
  const _AccessibilityReportDto({this.id = '', @JsonKey(name: 'user_id') this.userId = '', this.comments = '', @JsonKey(name: 'accessibility_level') this.level = AccessibilityLevel.medium});
  factory _AccessibilityReportDto.fromJson(Map<String, dynamic> json) => _$AccessibilityReportDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey() final  String comments;
@override@JsonKey(name: 'accessibility_level') final  AccessibilityLevel level;

/// Create a copy of AccessibilityReportDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccessibilityReportDtoCopyWith<_AccessibilityReportDto> get copyWith => __$AccessibilityReportDtoCopyWithImpl<_AccessibilityReportDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccessibilityReportDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccessibilityReportDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,comments,level);

@override
String toString() {
  return 'AccessibilityReportDto(id: $id, userId: $userId, comments: $comments, level: $level)';
}


}

/// @nodoc
abstract mixin class _$AccessibilityReportDtoCopyWith<$Res> implements $AccessibilityReportDtoCopyWith<$Res> {
  factory _$AccessibilityReportDtoCopyWith(_AccessibilityReportDto value, $Res Function(_AccessibilityReportDto) _then) = __$AccessibilityReportDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String comments,@JsonKey(name: 'accessibility_level') AccessibilityLevel level
});




}
/// @nodoc
class __$AccessibilityReportDtoCopyWithImpl<$Res>
    implements _$AccessibilityReportDtoCopyWith<$Res> {
  __$AccessibilityReportDtoCopyWithImpl(this._self, this._then);

  final _AccessibilityReportDto _self;
  final $Res Function(_AccessibilityReportDto) _then;

/// Create a copy of AccessibilityReportDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? comments = null,Object? level = null,}) {
  return _then(_AccessibilityReportDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as AccessibilityLevel,
  ));
}


}

// dart format on
