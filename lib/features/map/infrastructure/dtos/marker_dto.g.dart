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
          : const ColorConverter().fromJson(json['color'] as String),
  borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 2.0,
  borderColor:
      json['borderColor'] == null
          ? Colors.white
          : const ColorConverter().fromJson(json['borderColor'] as String),
  metadata:
      json['metadata'] == null
          ? const MarkerMetadata()
          : MarkerMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
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
      'color': const ColorConverter().toJson(instance.color),
      'borderWidth': instance.borderWidth,
      'borderColor': const ColorConverter().toJson(instance.borderColor),
      'metadata': instance.metadata,
    };

const _$MarkerTypeEnumMap = {
  MarkerType.currentLocation: 'currentLocation',
  MarkerType.pointOfInterest: 'pointOfInterest',
  MarkerType.destination: 'destination',
};
