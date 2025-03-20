// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marker_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarkerDto _$MarkerDtoFromJson(Map<String, dynamic> json) => _MarkerDto(
  id: json['id'] as String? ?? '',
  position: _latLngFromJson(json['position'] as Map<String, dynamic>),
  type:
      $enumDecodeNullable(_$MarkerTypeEnumMap, json['marker_type']) ??
      MarkerType.pointOfInterest,
  title: json['title'] as String? ?? '',
  description: json['description'] as String? ?? '',
  width: (json['width'] as num?)?.toDouble() ?? 40.0,
  height: (json['height'] as num?)?.toDouble() ?? 40.0,
  color:
      json['color'] == null
          ? Colors.red
          : _colorFromJson(json['color'] as String),
  borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 2.0,
  borderColor:
      json['borderColor'] == null
          ? Colors.white
          : _colorFromJson(json['borderColor'] as String),
);

Map<String, dynamic> _$MarkerDtoToJson(_MarkerDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'position': _latLngToJson(instance.position),
      'marker_type': _$MarkerTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'width': instance.width,
      'height': instance.height,
      'color': _colorToJson(instance.color),
      'borderWidth': instance.borderWidth,
      'borderColor': _colorToJson(instance.borderColor),
    };

const _$MarkerTypeEnumMap = {
  MarkerType.currentLocation: 'currentLocation',
  MarkerType.pointOfInterest: 'pointOfInterest',
  MarkerType.destination: 'destination',
};
