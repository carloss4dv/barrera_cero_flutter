import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String name;
  final MobilityType mobilityType;
  final List<AccessibilityPreference> accessibilityPreferences;
  final int contributionPoints;
  final List<Badge> badges;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.mobilityType = MobilityType.noAssistance,
    this.accessibilityPreferences = const [],
    this.contributionPoints = 0,
    this.badges = const [],
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convertir User a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'mobilityType': mobilityType.toString().split('.').last,
      'accessibilityPreferences': accessibilityPreferences
          .map((pref) => pref.toString().split('.').last)
          .toList(),
      'contributionPoints': contributionPoints,
      'badges': badges.map((badge) => badge.toMap()).toList(),
      'isVerified': isVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Crear User desde Map de Firestore
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      mobilityType: MobilityType.values.firstWhere(
          (e) => e.toString().split('.').last == map['mobilityType']),
      accessibilityPreferences: (map['accessibilityPreferences'] as List)
          .map((pref) => AccessibilityPreference.values.firstWhere(
              (e) => e.toString().split('.').last == pref))
          .toList(),
      contributionPoints: map['contributionPoints'] ?? 0,
      badges: ((map['badges'] as List?) ?? [])
          .map((badge) => Badge.fromMap(badge))
          .toList(),
      isVerified: map['isVerified'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}

enum MobilityType {
  wheelchair,
  cane,
  walker,
  visuallyImpaired,
  hearingImpaired,
  noAssistance,
  other
}

// Extensión para traducir los tipos de movilidad al español
extension MobilityTypeExtension on MobilityType {
  String get displayName {
    switch (this) {
      case MobilityType.wheelchair:
        return 'Silla de ruedas';
      case MobilityType.cane:
        return 'Bastón';
      case MobilityType.walker:
        return 'Andador';
      case MobilityType.visuallyImpaired:
        return 'Discapacidad visual';
      case MobilityType.hearingImpaired:
        return 'Discapacidad auditiva';
      case MobilityType.noAssistance:
        return 'Sin asistencia';
      case MobilityType.other:
        return 'Otro';
    }
  }
}

enum AccessibilityPreference {
  ramps,
  elevators,
  adaptedBathrooms,
  wideCorridors,
  lowInclination,
  audioSignals,
  visualSignals,
  highContrast,
  textToSpeech
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final DateTime earnedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.earnedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'earnedAt': earnedAt,
    };
  }

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      iconUrl: map['iconUrl'],
      earnedAt: (map['earnedAt'] as Timestamp).toDate(),
    );
  }
}