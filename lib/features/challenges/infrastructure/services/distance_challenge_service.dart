import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../domain/challenge_model.dart';
import '../../../users/services/user_service.dart';
import 'distance_tracking_service.dart';
import '../../../../services/local_user_storage_service.dart';

class DistanceChallengeService {
  final UserService _userService;
  final DistanceTrackingService _distanceTrackingService;
  
  // Callback para notificar cuando se completa un desafío
  Function(Challenge challenge, int pointsAwarded)? onChallengeCompleted;

  DistanceChallengeService(this._userService, this._distanceTrackingService) {
    // Configurar el callback para recibir notificaciones de cambios de distancia
    _distanceTrackingService.onDistanceUpdated = _onDistanceUpdated;
  }

  /// Callback que se ejecuta cuando la distancia se actualiza
  void _onDistanceUpdated(double newDistance) async {
    print('=== DEBUG: DistanceChallengeService._onDistanceUpdated() - Nueva distancia: ${newDistance.toStringAsFixed(2)}m ===');
    
    // Verificar todos los desafíos de distancia para ver si alguno se completó
    await _checkDistanceChallengesCompletion();
  }
  /// Verifica si algún desafío de distancia se completó con la nueva distancia
  Future<void> _checkDistanceChallengesCompletion() async {
    try {
      // Importar los desafíos base
      final baseChallenges = _getBaseDistanceChallenges();
      
      for (final challenge in baseChallenges) {
        if (challenge.type == ChallengeType.distance) {
          await updateChallengeProgress(challenge);
          // Si se completó, el callback ya se habrá ejecutado en updateChallengeProgress
        }
      }
    } catch (e) {
      print('=== ERROR: Error verificando completación de desafíos de distancia: $e ===');
    }
  }

  /// Obtiene los desafíos de distancia base
  List<Challenge> _getBaseDistanceChallenges() {
    return [
      Challenge(
        id: '6',
        title: 'Primer kilometro',
        description: 'Recorre 1 kilómetro caminando',
        icon: Icons.directions_walk,
        points: 100,
        type: ChallengeType.distance,
        target: 1000, // 1 km en metros
        isCompleted: false,
      ),
      Challenge(
        id: '7',
        title: 'Caminante dedicado',
        description: 'Recorre 10 kilómetros caminando',
        icon: Icons.hiking,
        points: 500,
        type: ChallengeType.distance,
        target: 10000, // 10 km en metros
        isCompleted: false,
      ),
      Challenge(
        id: '8',
        title: 'Explorador incansable',
        description: 'Recorre 100 kilómetros caminando',
        icon: Icons.explore,
        points: 1000,
        type: ChallengeType.distance,
        target: 100000, // 100 km en metros
        isCompleted: false,
      ),
    ];
  }

  /// Actualiza el progreso de un desafío de distancia
  /// Si [justStartedTracking] es true, indica que se acaba de iniciar el tracking
  Future<Challenge> updateChallengeProgress(Challenge challenge, {bool justStartedTracking = false}) async {
    print('=== DEBUG: DistanceChallengeService.updateChallengeProgress() - INICIANDO para: ${challenge.title}, justStartedTracking: $justStartedTracking ===');
    
    if (challenge.type != ChallengeType.distance) {
      print('=== DEBUG: El desafío no es de tipo distancia, retornando sin cambios ===');
      return challenge;
    }
    
    // Obtener el usuario actual
    final localUserStorage = LocalUserStorageService();
    await localUserStorage.init();
    final currentUserId = await localUserStorage.getUserId();
    
    if (currentUserId == null) {
      print('=== DEBUG: No se pudo obtener el UID del usuario actual ===');
      return challenge;
    }    // Obtener la distancia total recorrida
    final totalDistanceMeters = _distanceTrackingService.totalDistance;
    final isCompleted = totalDistanceMeters >= challenge.target;
    
    // Verificar si ya había sido completado antes
    final wasAlreadyCompleted = await _wasAlreadyCompleted(challenge.id, currentUserId);
    
    // El estado final de completado es TRUE si la distancia se alcanzó O si ya estaba marcado como completado
    final finalIsCompleted = isCompleted || wasAlreadyCompleted;
    
    print('=== DEBUG: Distancia del usuario: ${totalDistanceMeters.toStringAsFixed(2)}m, Target: ${challenge.target}m, Completado por distancia: $isCompleted, Ya completado antes: $wasAlreadyCompleted, Estado final: $finalIsCompleted ===');
    
    // Solo otorgar puntos si se acaba de completar y no estaba completado antes
    if (isCompleted && !wasAlreadyCompleted) {
      print('=== DEBUG: ¡Desafío de distancia completado! Otorgando ${challenge.points} B-points ===');
      try {
        await _userService.addBPoints(challenge.points);
        await _markChallengeAsCompleted(challenge.id, currentUserId);
        print('=== DEBUG: B-points otorgados exitosamente y desafío marcado como completado ===');
        
        // Notificar a la UI sobre la completación del desafío
        // Asegurarse de que el desafío notificado esté marcado como completado y con el progreso al máximo
        onChallengeCompleted?.call(challenge.copyWith(isCompleted: true, currentProgress: challenge.target), challenge.points);
        
      } catch (e) {
        print('=== ERROR: Error otorgando B-points: $e ===');
      }
    } else if (finalIsCompleted) {
      // Desafío ya estaba completado, no es necesario marcarlo de nuevo ni otorgar puntos.
      print('=== DEBUG: Desafío de distancia (${challenge.title}) ya estaba completado anteriormente. ===');
    }

    return challenge.copyWith(
      currentProgress: finalIsCompleted ? challenge.target : totalDistanceMeters.round(), // Si está completado, mostrar progreso completo
      isCompleted: finalIsCompleted, // Usar el estado final de completado
    );
  }

  /// Verifica si un desafío ya fue completado previamente
  Future<bool> _wasAlreadyCompleted(String challengeId, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'distance_challenge_completed_${challengeId}_$userId';
      return prefs.getBool(key) ?? false;
    } catch (e) {
      print('ERROR: Error verificando estado del desafío de distancia: $e');
      return false;
    }
  }

  /// Marca un desafío como completado
  Future<void> _markChallengeAsCompleted(String challengeId, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'distance_challenge_completed_${challengeId}_$userId';
      await prefs.setBool(key, true);
      print('=== DEBUG: Desafío de distancia $challengeId marcado como completado para usuario $userId ===');
    } catch (e) {
      print('ERROR: Error marcando desafío de distancia como completado: $e');
    }
  }

  /// Limpia todos los datos del usuario (para logout)
  static Future<void> clearAllUserDataOnLogout() async {
    try {
      final localUserStorage = LocalUserStorageService();
      await localUserStorage.init();
      final currentUserId = await localUserStorage.getUserId();
      
      if (currentUserId != null) {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys().toList();
        
        // Eliminar claves relacionadas con desafíos de distancia
        for (final key in keys) {
          if (key.contains('distance_challenge_completed_') && key.contains(currentUserId)) {
            await prefs.remove(key);
          }
        }
        
        print('✅ Todos los datos de desafíos de distancia limpiados para usuario: $currentUserId');
      }
    } catch (e) {
      print('❌ Error limpiando datos de desafíos de distancia en logout: $e');
    }
  }
  /// Verifica si un desafío de distancia ha sido completado
  Future<bool> isChallengeCompleted(Challenge challenge) async {
    if (challenge.type != ChallengeType.distance) return challenge.isCompleted;
    
    // Obtener el usuario actual
    final localUserStorage = LocalUserStorageService();
    await localUserStorage.init();
    final currentUserId = await localUserStorage.getUserId();
    
    if (currentUserId == null) return false;
    
    // Verificar si ya fue marcado como completado previamente
    final wasAlreadyCompleted = await _wasAlreadyCompleted(challenge.id, currentUserId);
    if (wasAlreadyCompleted) return true;
    
    // Si no estaba marcado como completado, verificar por distancia
    final totalDistance = _distanceTrackingService.totalDistance;
    return totalDistance >= challenge.target;
  }
  /// Obtiene el progreso actual de un desafío de distancia
  Future<int> getCurrentProgress(Challenge challenge) async {
    if (challenge.type != ChallengeType.distance) return challenge.currentProgress;
    
    // Verificar si ya está completado
    final isCompleted = await isChallengeCompleted(challenge);
    if (isCompleted) return challenge.target;
    
    // Si no está completado, calcular progreso basado en distancia actual
    final totalDistance = _distanceTrackingService.totalDistance;
    return totalDistance.round().clamp(0, challenge.target);
  }

  /// Obtiene la distancia total en metros
  double getTotalDistanceMeters() {
    return _distanceTrackingService.totalDistance;
  }

  /// Obtiene la distancia total en kilómetros
  double getTotalDistanceKm() {
    return _distanceTrackingService.totalDistanceInKm;
  }
}