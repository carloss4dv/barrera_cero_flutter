import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/challenge_model.dart';
import '../../../users/services/user_service.dart';
import 'distance_tracking_service.dart';
import '../../../../services/local_user_storage_service.dart';

class DistanceChallengeService {
  final UserService _userService;
  final DistanceTrackingService _distanceTrackingService;
  
  // Callback para notificar cuando se completa un desafío
  Function(Challenge challenge, int pointsAwarded)? onChallengeCompleted;

  DistanceChallengeService(this._userService, this._distanceTrackingService);

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
    }
    
    // Obtener la distancia total recorrida
    final totalDistanceMeters = _distanceTrackingService.totalDistance;
    final currentProgress = (totalDistanceMeters / challenge.target * challenge.target).round();
    final isCompleted = totalDistanceMeters >= challenge.target;
    
    // Verificar si ya había sido completado antes
    final wasAlreadyCompleted = await _wasAlreadyCompleted(challenge.id, currentUserId);
    
    print('=== DEBUG: Distancia del usuario: ${totalDistanceMeters.toStringAsFixed(2)}m, Target: ${challenge.target}m, Completado: $isCompleted, Ya completado antes: $wasAlreadyCompleted ===');
    
    // Solo otorgar puntos si se acaba de completar y no estaba completado antes
    if (isCompleted && !wasAlreadyCompleted) {
      print('=== DEBUG: ¡Desafío de distancia completado! Otorgando ${challenge.points} B-points ===');
      try {
        await _userService.addBPoints(challenge.points);
        await _markChallengeAsCompleted(challenge.id, currentUserId);
        print('=== DEBUG: B-points otorgados exitosamente y desafío marcado como completado ===');
        
        // Notificar a la UI sobre la completación del desafío
        onChallengeCompleted?.call(challenge, challenge.points);
        
      } catch (e) {
        print('=== ERROR: Error otorgando B-points: $e ===');
      }
    } else if (isCompleted && wasAlreadyCompleted) {
      // Solo marcar como completado pero no otorgar puntos si ya estaba completado
      print('=== DEBUG: Desafío ya estaba completado anteriormente - Solo marcando como completado sin otorgar puntos ===');
      try {
        await _markChallengeAsCompleted(challenge.id, currentUserId);
        print('=== DEBUG: Desafío marcado como completado (sin puntos por ser antiguo) ===');
      } catch (e) {
        print('=== ERROR: Error marcando desafío como completado: $e ===');
      }
    }

    return challenge.copyWith(
      currentProgress: currentProgress,
      isCompleted: isCompleted,
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
    
    final totalDistance = _distanceTrackingService.totalDistance;
    return totalDistance >= challenge.target;
  }

  /// Obtiene el progreso actual de un desafío de distancia
  int getCurrentProgress(Challenge challenge) {
    if (challenge.type != ChallengeType.distance) return challenge.currentProgress;
    
    final totalDistance = _distanceTrackingService.totalDistance;
    return (totalDistance / challenge.target * challenge.target).round();
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