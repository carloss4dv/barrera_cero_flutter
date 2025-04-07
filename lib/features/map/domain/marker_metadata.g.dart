// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marker_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarkerMetadata _$MarkerMetadataFromJson(Map<String, dynamic> json) =>
    _MarkerMetadata(
      hasRamp: json['hasRamp'] as bool? ?? false,
      hasElevator: json['hasElevator'] as bool? ?? false,
      hasAccessibleBathroom: json['hasAccessibleBathroom'] as bool? ?? false,
      hasBrailleSignage: json['hasBrailleSignage'] as bool? ?? false,
      hasAudioGuidance: json['hasAudioGuidance'] as bool? ?? false,
      hasTactilePavement: json['hasTactilePavement'] as bool? ?? false,
      additionalNotes: json['additionalNotes'] as String? ?? '',
      accessibilityScore: (json['accessibilityScore'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MarkerMetadataToJson(_MarkerMetadata instance) =>
    <String, dynamic>{
      'hasRamp': instance.hasRamp,
      'hasElevator': instance.hasElevator,
      'hasAccessibleBathroom': instance.hasAccessibleBathroom,
      'hasBrailleSignage': instance.hasBrailleSignage,
      'hasAudioGuidance': instance.hasAudioGuidance,
      'hasTactilePavement': instance.hasTactilePavement,
      'additionalNotes': instance.additionalNotes,
      'accessibilityScore': instance.accessibilityScore,
    };
