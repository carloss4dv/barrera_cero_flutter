import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

class ColorConverter implements JsonConverter<Color, String> {
  const ColorConverter();

  @override
  Color fromJson(String json) {
    return Color(int.parse(json));
  }

  @override
  String toJson(Color color) {
    return color.value.toString();
  }
} 