import 'package:flutter/material.dart';

enum ChallengeType {
  reports,
  walking,
  visits,
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int points;
  final bool isCompleted;
  final ChallengeType type;
  final int target;
  final int currentProgress;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.type,
    required this.target,
    this.isCompleted = false,
    this.currentProgress = 0,
  });

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    int? points,
    bool? isCompleted,
    ChallengeType? type,
    int? target,
    int? currentProgress,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
      target: target ?? this.target,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  double get progressPercentage {
    if (target == 0) return 0.0;
    return (currentProgress / target).clamp(0.0, 1.0);
  }
}
