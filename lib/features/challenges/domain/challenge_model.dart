import 'package:flutter/material.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int points;
  final bool isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    this.isCompleted = false,
  });
}
