// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accessibility_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccessibilityReportModel {

 String get id; String get userId; String get userName; String get comments; AccessibilityLevel get level;
/// Create a copy of AccessibilityReportModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccessibilityReportModelCopyWith<AccessibilityReportModel> get copyWith => _$AccessibilityReportModelCopyWithImpl<AccessibilityReportModel>(this as AccessibilityReportModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccessibilityReportModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.level, level) || other.level == level));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,comments,level);

@override
String toString() {
  return 'AccessibilityReportModel(id: $id, userId: $userId, userName: $userName, comments: $comments, level: $level)';
}


}

/// @nodoc
abstract mixin class $AccessibilityReportModelCopyWith<$Res>  {
  factory $AccessibilityReportModelCopyWith(AccessibilityReportModel value, $Res Function(AccessibilityReportModel) _then) = _$AccessibilityReportModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String userName, String comments, AccessibilityLevel level
});




}
/// @nodoc
class _$AccessibilityReportModelCopyWithImpl<$Res>
    implements $AccessibilityReportModelCopyWith<$Res> {
  _$AccessibilityReportModelCopyWithImpl(this._self, this._then);

  final AccessibilityReportModel _self;
  final $Res Function(AccessibilityReportModel) _then;

/// Create a copy of AccessibilityReportModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? comments = null,Object? level = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as AccessibilityLevel,
  ));
}

}


/// @nodoc


class _AccessibilityReportModel implements AccessibilityReportModel {
  const _AccessibilityReportModel({required this.id, required this.userId, required this.userName, required this.comments, required this.level});
  

@override final  String id;
@override final  String userId;
@override final  String userName;
@override final  String comments;
@override final  AccessibilityLevel level;

/// Create a copy of AccessibilityReportModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccessibilityReportModelCopyWith<_AccessibilityReportModel> get copyWith => __$AccessibilityReportModelCopyWithImpl<_AccessibilityReportModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccessibilityReportModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.level, level) || other.level == level));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,comments,level);

@override
String toString() {
  return 'AccessibilityReportModel(id: $id, userId: $userId, userName: $userName, comments: $comments, level: $level)';
}


}

/// @nodoc
abstract mixin class _$AccessibilityReportModelCopyWith<$Res> implements $AccessibilityReportModelCopyWith<$Res> {
  factory _$AccessibilityReportModelCopyWith(_AccessibilityReportModel value, $Res Function(_AccessibilityReportModel) _then) = __$AccessibilityReportModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String userName, String comments, AccessibilityLevel level
});




}
/// @nodoc
class __$AccessibilityReportModelCopyWithImpl<$Res>
    implements _$AccessibilityReportModelCopyWith<$Res> {
  __$AccessibilityReportModelCopyWithImpl(this._self, this._then);

  final _AccessibilityReportModel _self;
  final $Res Function(_AccessibilityReportModel) _then;

/// Create a copy of AccessibilityReportModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? comments = null,Object? level = null,}) {
  return _then(_AccessibilityReportModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as AccessibilityLevel,
  ));
}


}

// dart format on
