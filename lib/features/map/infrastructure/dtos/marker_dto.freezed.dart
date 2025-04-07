// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marker_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MarkerDto {

 String get id;@JsonKey(fromJson: _latLngFromJson, toJson: _latLngToJson) LatLng get position;@JsonKey(name: 'marker_type') MarkerType get type; String get title; String get description; double get width; double get height;@ColorConverter() Color get color; double get borderWidth;@ColorConverter() Color get borderColor; MarkerMetadata get metadata;
/// Create a copy of MarkerDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkerDtoCopyWith<MarkerDto> get copyWith => _$MarkerDtoCopyWithImpl<MarkerDto>(this as MarkerDto, _$identity);

  /// Serializes this MarkerDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.position, position) || other.position == position)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.color, color) || other.color == color)&&(identical(other.borderWidth, borderWidth) || other.borderWidth == borderWidth)&&(identical(other.borderColor, borderColor) || other.borderColor == borderColor)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,position,type,title,description,width,height,color,borderWidth,borderColor,metadata);

@override
String toString() {
  return 'MarkerDto(id: $id, position: $position, type: $type, title: $title, description: $description, width: $width, height: $height, color: $color, borderWidth: $borderWidth, borderColor: $borderColor, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $MarkerDtoCopyWith<$Res>  {
  factory $MarkerDtoCopyWith(MarkerDto value, $Res Function(MarkerDto) _then) = _$MarkerDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(fromJson: _latLngFromJson, toJson: _latLngToJson) LatLng position,@JsonKey(name: 'marker_type') MarkerType type, String title, String description, double width, double height,@ColorConverter() Color color, double borderWidth,@ColorConverter() Color borderColor, MarkerMetadata metadata
});


$MarkerMetadataCopyWith<$Res> get metadata;

}
/// @nodoc
class _$MarkerDtoCopyWithImpl<$Res>
    implements $MarkerDtoCopyWith<$Res> {
  _$MarkerDtoCopyWithImpl(this._self, this._then);

  final MarkerDto _self;
  final $Res Function(MarkerDto) _then;

/// Create a copy of MarkerDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? position = null,Object? type = null,Object? title = null,Object? description = null,Object? width = null,Object? height = null,Object? color = null,Object? borderWidth = null,Object? borderColor = null,Object? metadata = null,}) {
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
as Color,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as MarkerMetadata,
  ));
}
/// Create a copy of MarkerDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarkerMetadataCopyWith<$Res> get metadata {
  
  return $MarkerMetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _MarkerDto implements MarkerDto {
  const _MarkerDto({this.id = '', @JsonKey(fromJson: _latLngFromJson, toJson: _latLngToJson) required this.position, @JsonKey(name: 'marker_type') this.type = MarkerType.pointOfInterest, this.title = '', this.description = '', this.width = 40.0, this.height = 40.0, @ColorConverter() this.color = Colors.red, this.borderWidth = 2.0, @ColorConverter() this.borderColor = Colors.white, this.metadata = const MarkerMetadata()});
  factory _MarkerDto.fromJson(Map<String, dynamic> json) => _$MarkerDtoFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(fromJson: _latLngFromJson, toJson: _latLngToJson) final  LatLng position;
@override@JsonKey(name: 'marker_type') final  MarkerType type;
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override@JsonKey() final  double width;
@override@JsonKey() final  double height;
@override@JsonKey()@ColorConverter() final  Color color;
@override@JsonKey() final  double borderWidth;
@override@JsonKey()@ColorConverter() final  Color borderColor;
@override@JsonKey() final  MarkerMetadata metadata;

/// Create a copy of MarkerDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkerDtoCopyWith<_MarkerDto> get copyWith => __$MarkerDtoCopyWithImpl<_MarkerDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarkerDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.position, position) || other.position == position)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.color, color) || other.color == color)&&(identical(other.borderWidth, borderWidth) || other.borderWidth == borderWidth)&&(identical(other.borderColor, borderColor) || other.borderColor == borderColor)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,position,type,title,description,width,height,color,borderWidth,borderColor,metadata);

@override
String toString() {
  return 'MarkerDto(id: $id, position: $position, type: $type, title: $title, description: $description, width: $width, height: $height, color: $color, borderWidth: $borderWidth, borderColor: $borderColor, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$MarkerDtoCopyWith<$Res> implements $MarkerDtoCopyWith<$Res> {
  factory _$MarkerDtoCopyWith(_MarkerDto value, $Res Function(_MarkerDto) _then) = __$MarkerDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(fromJson: _latLngFromJson, toJson: _latLngToJson) LatLng position,@JsonKey(name: 'marker_type') MarkerType type, String title, String description, double width, double height,@ColorConverter() Color color, double borderWidth,@ColorConverter() Color borderColor, MarkerMetadata metadata
});


@override $MarkerMetadataCopyWith<$Res> get metadata;

}
/// @nodoc
class __$MarkerDtoCopyWithImpl<$Res>
    implements _$MarkerDtoCopyWith<$Res> {
  __$MarkerDtoCopyWithImpl(this._self, this._then);

  final _MarkerDto _self;
  final $Res Function(_MarkerDto) _then;

/// Create a copy of MarkerDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? position = null,Object? type = null,Object? title = null,Object? description = null,Object? width = null,Object? height = null,Object? color = null,Object? borderWidth = null,Object? borderColor = null,Object? metadata = null,}) {
  return _then(_MarkerDto(
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
as Color,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as MarkerMetadata,
  ));
}

/// Create a copy of MarkerDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MarkerMetadataCopyWith<$Res> get metadata {
  
  return $MarkerMetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}

// dart format on
