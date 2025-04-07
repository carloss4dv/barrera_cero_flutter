import 'package:freezed_annotation/freezed_annotation.dart';

part 'marker_metadata.freezed.dart';
part 'marker_metadata.g.dart';

@freezed
abstract class MarkerMetadata with _$MarkerMetadata {
  const factory MarkerMetadata({
    @Default(false) bool hasRamp,
    @Default(false) bool hasElevator,
    @Default(false) bool hasAccessibleBathroom,
    @Default(false) bool hasBrailleSignage,
    @Default(false) bool hasAudioGuidance,
    @Default(false) bool hasTactilePavement,
    @Default('') String additionalNotes,
    @Default(0) int accessibilityScore,
  }) = _MarkerMetadata;

  factory MarkerMetadata.fromJson(Map<String, dynamic> json) =>
      _$MarkerMetadataFromJson(json);
} 