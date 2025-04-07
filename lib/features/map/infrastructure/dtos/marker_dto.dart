import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import '../../domain/marker_model.dart';
import '../../domain/marker_metadata.dart';
import '../converters/color_converter.dart';

part 'marker_dto.freezed.dart';
part 'marker_dto.g.dart';

@freezed
class MarkerDto with _$MarkerDto {
  const factory MarkerDto({
    @Default('') String id,
    @JsonKey(
      fromJson: _latLngFromJson,
      toJson: _latLngToJson,
    )
    required LatLng position,
    @JsonKey(name: 'marker_type')
    @Default(MarkerType.pointOfInterest) MarkerType type,
    @Default('') String title,
    @Default('') String description,
    @Default(40.0) double width,
    @Default(40.0) double height,
    @ColorConverter()
    @Default(Colors.red) Color color,
    @Default(2.0) double borderWidth,
    @ColorConverter()
    @Default(Colors.white) Color borderColor,
    @Default(MarkerMetadata()) MarkerMetadata metadata,
  }) = _MarkerDto;

  factory MarkerDto.fromJson(Map<String, dynamic> json) =>
      _$MarkerDtoFromJson(json);

  factory MarkerDto.fromDomain(MarkerModel model) => MarkerDto(
        id: model.id,
        position: model.position,
        type: model.type,
        title: model.title,
        description: model.description,
        width: model.width,
        height: model.height,
        color: model.color,
        borderWidth: model.borderWidth,
        borderColor: model.borderColor,
        metadata: model.metadata,
      );
}

extension MarkerDtoX on MarkerDto {
  MarkerModel toDomain() => MarkerModel(
        id: id,
        position: position,
        type: type,
        title: title,
        description: description,
        width: width,
        height: height,
        color: color,
        borderWidth: borderWidth,
        borderColor: borderColor,
        metadata: metadata,
      );
}

LatLng _latLngFromJson(Map<String, dynamic> json) {
  return LatLng(
    json['latitude'] as double,
    json['longitude'] as double,
  );
}

Map<String, dynamic> _latLngToJson(LatLng latLng) {
  return {
    'latitude': latLng.latitude,
    'longitude': latLng.longitude,
  };
}

Color _colorFromJson(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

String _colorToJson(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
} 