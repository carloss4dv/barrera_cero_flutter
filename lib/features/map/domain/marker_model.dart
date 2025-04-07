import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'marker_metadata.dart';
import '../infrastructure/converters/color_converter.dart';

part 'marker_model.freezed.dart';
part 'marker_model.g.dart';

@freezed
abstract class MarkerModel with _$MarkerModel {
  const factory MarkerModel({
    required String id,
    required LatLng position,
    required MarkerType type,
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
  }) = _MarkerModel;

  factory MarkerModel.fromJson(Map<String, dynamic> json) =>
      _$MarkerModelFromJson(json);

  factory MarkerModel.empty() => const MarkerModel(
        id: '',
        position: LatLng(0, 0),
        type: MarkerType.pointOfInterest,
      );

  factory MarkerModel.currentLocation({
    required String id,
    required LatLng position,
  }) => MarkerModel(
        id: id,
        position: position,
        type: MarkerType.currentLocation,
        color: Colors.red,
      );

  factory MarkerModel.pointOfInterest({
    required String id,
    required LatLng position,
    required String title,
    String description = '',
    MarkerMetadata? metadata,
  }) => MarkerModel(
        id: id,
        position: position,
        type: MarkerType.pointOfInterest,
        title: title,
        description: description,
        color: Colors.green,
        metadata: metadata ?? const MarkerMetadata(),
      );

  factory MarkerModel.destination({
    required String id,
    required LatLng position,
    required String title,
    String description = '',
    MarkerMetadata? metadata,
  }) => MarkerModel(
        id: id,
        position: position,
        type: MarkerType.destination,
        title: title,
        description: description,
        color: Colors.amber,
        metadata: metadata ?? const MarkerMetadata(),
      );
}

enum MarkerType {
  currentLocation,
  pointOfInterest,
  destination
} 