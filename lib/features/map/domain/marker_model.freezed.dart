// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marker_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarkerModel {

 String get id; LatLng get position; MarkerType get type; String get title; String get description; double get width; double get height; Color get color; double get borderWidth; Color get borderColor;
/// Create a copy of MarkerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkerModelCopyWith<MarkerModel> get copyWith => _$MarkerModelCopyWithImpl<MarkerModel>(this as MarkerModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.position, position) || other.position == position)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.color, color) || other.color == color)&&(identical(other.borderWidth, borderWidth) || other.borderWidth == borderWidth)&&(identical(other.borderColor, borderColor) || other.borderColor == borderColor));
}


@override
int get hashCode => Object.hash(runtimeType,id,position,type,title,description,width,height,color,borderWidth,borderColor);

@override
String toString() {
  return 'MarkerModel(id: $id, position: $position, type: $type, title: $title, description: $description, width: $width, height: $height, color: $color, borderWidth: $borderWidth, borderColor: $borderColor)';
}


}

/// @nodoc
abstract mixin class $MarkerModelCopyWith<$Res>  {
  factory $MarkerModelCopyWith(MarkerModel value, $Res Function(MarkerModel) _then) = _$MarkerModelCopyWithImpl;
@useResult
$Res call({
 String id, LatLng position, MarkerType type, String title, String description, double width, double height, Color color, double borderWidth, Color borderColor
});




}
/// @nodoc
class _$MarkerModelCopyWithImpl<$Res>
    implements $MarkerModelCopyWith<$Res> {
  _$MarkerModelCopyWithImpl(this._self, this._then);

  final MarkerModel _self;
  final $Res Function(MarkerModel) _then;

/// Create a copy of MarkerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? position = null,Object? type = null,Object? title = null,Object? description = null,Object? width = null,Object? height = null,Object? color = null,Object? borderWidth = null,Object? borderColor = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as LatLng,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MarkerType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,borderWidth: null == borderWidth ? _self.borderWidth : borderWidth // ignore: cast_nullable_to_non_nullable
as double,borderColor: null == borderColor ? _self.borderColor : borderColor // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}

}


/// @nodoc


class _MarkerModel implements MarkerModel {
  const _MarkerModel({required this.id, required this.position, required this.type, this.title = '', this.description = '', this.width = 40.0, this.height = 40.0, this.color = Colors.red, this.borderWidth = 2.0, this.borderColor = Colors.white});
  

@override final  String id;
@override final  LatLng position;
@override final  MarkerType type;
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override@JsonKey() final  double width;
@override@JsonKey() final  double height;
@override@JsonKey() final  Color color;
@override@JsonKey() final  double borderWidth;
@override@JsonKey() final  Color borderColor;

/// Create a copy of MarkerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkerModelCopyWith<_MarkerModel> get copyWith => __$MarkerModelCopyWithImpl<_MarkerModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.position, position) || other.position == position)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.color, color) || other.color == color)&&(identical(other.borderWidth, borderWidth) || other.borderWidth == borderWidth)&&(identical(other.borderColor, borderColor) || other.borderColor == borderColor));
}


@override
int get hashCode => Object.hash(runtimeType,id,position,type,title,description,width,height,color,borderWidth,borderColor);

@override
String toString() {
  return 'MarkerModel(id: $id, position: $position, type: $type, title: $title, description: $description, width: $width, height: $height, color: $color, borderWidth: $borderWidth, borderColor: $borderColor)';
}


}

/// @nodoc
abstract mixin class _$MarkerModelCopyWith<$Res> implements $MarkerModelCopyWith<$Res> {
  factory _$MarkerModelCopyWith(_MarkerModel value, $Res Function(_MarkerModel) _then) = __$MarkerModelCopyWithImpl;
@override @useResult
$Res call({
 String id, LatLng position, MarkerType type, String title, String description, double width, double height, Color color, double borderWidth, Color borderColor
});




}
/// @nodoc
class __$MarkerModelCopyWithImpl<$Res>
    implements _$MarkerModelCopyWith<$Res> {
  __$MarkerModelCopyWithImpl(this._self, this._then);

  final _MarkerModel _self;
  final $Res Function(_MarkerModel) _then;

/// Create a copy of MarkerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? position = null,Object? type = null,Object? title = null,Object? description = null,Object? width = null,Object? height = null,Object? color = null,Object? borderWidth = null,Object? borderColor = null,}) {
  return _then(_MarkerModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as LatLng,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MarkerType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,borderWidth: null == borderWidth ? _self.borderWidth : borderWidth // ignore: cast_nullable_to_non_nullable
as double,borderColor: null == borderColor ? _self.borderColor : borderColor // ignore: cast_nullable_to_non_nullable
as Color,
  ));
}


}

// dart format on
