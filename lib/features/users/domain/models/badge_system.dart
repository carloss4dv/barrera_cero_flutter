import 'package:flutter/material.dart';

enum BadgeType {
  contributor,
  champion,
  legend,
}

class BadgeInfo {
  final BadgeType type;
  final String name;
  final String description;
  final String assetPath;
  final int requiredPoints;
  final Color color;

  const BadgeInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.assetPath,
    required this.requiredPoints,
    required this.color,
  });
}

class BadgeSystem {
  static const List<BadgeInfo> _badges = [    BadgeInfo(
      type: BadgeType.contributor,
      name: 'Contribuidor',
      description: 'Has contribuido con la comunidad',
      assetPath: 'assets/badges/contributor.png',
      requiredPoints: 100,
      color: Color(0xFF4CAF50), // Verde
    ),
    BadgeInfo(
      type: BadgeType.champion,
      name: 'Campeón',
      description: 'Eres un campeón de la accesibilidad',
      assetPath: 'assets/badges/champion.png',
      requiredPoints: 1000,
      color: Color(0xFF2196F3), // Azul
    ),
    BadgeInfo(
      type: BadgeType.legend,
      name: 'Leyenda',
      description: 'Eres una leyenda de la accesibilidad',
      assetPath: 'assets/badges/legend.png',
      requiredPoints: 10000,
      color: Color(0xFFFF9800), // Naranja
    ),
  ];

  /// Obtiene todas las insignias disponibles
  static List<BadgeInfo> getAllBadges() => _badges;

  /// Obtiene las insignias que el usuario ha desbloqueado basándose en sus B-points
  static List<BadgeInfo> getEarnedBadges(int bPoints) {
    return _badges.where((badge) => bPoints >= badge.requiredPoints).toList();
  }

  /// Obtiene la siguiente insignia que el usuario puede desbloquear
  static BadgeInfo? getNextBadge(int bPoints) {
    final unearnedBadges = _badges.where((badge) => bPoints < badge.requiredPoints).toList();
    if (unearnedBadges.isEmpty) return null;
    
    // Devolver la insignia con menor requerimiento de puntos
    unearnedBadges.sort((a, b) => a.requiredPoints.compareTo(b.requiredPoints));
    return unearnedBadges.first;
  }

  /// Calcula cuántos puntos faltan para la siguiente insignia
  static int getPointsToNextBadge(int bPoints) {
    final nextBadge = getNextBadge(bPoints);
    if (nextBadge == null) return 0;
    return nextBadge.requiredPoints - bPoints;
  }

  /// Verifica si el usuario acaba de desbloquear una nueva insignia
  static BadgeInfo? checkNewBadgeUnlocked(int oldPoints, int newPoints) {
    final oldBadges = getEarnedBadges(oldPoints);
    final newBadges = getEarnedBadges(newPoints);
    
    if (newBadges.length > oldBadges.length) {
      // Encontrar la nueva insignia desbloqueada
      final newBadgeTypes = newBadges.map((b) => b.type).toSet();
      final oldBadgeTypes = oldBadges.map((b) => b.type).toSet();
      final unlockedType = newBadgeTypes.difference(oldBadgeTypes).first;
      
      return _badges.firstWhere((badge) => badge.type == unlockedType);
    }
    
    return null;
  }
}
