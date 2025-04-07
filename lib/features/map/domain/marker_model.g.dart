// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarkerModel _$MarkerModelFromJson(Map<String, dynamic> json) => _MarkerModel(
  id: json['id'] as String,
  position: LatLng.fromJson(json['position'] as Map<String, dynamic>),
  type: $enumDecode(_$MarkerTypeEnumMap, json['type']),
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

Map<String, dynamic> _$MarkerModelToJson(_MarkerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'position': instance.position,
      'type': _$MarkerTypeEnumMap[instance.type]!,
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
