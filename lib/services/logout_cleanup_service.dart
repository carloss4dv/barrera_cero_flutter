import 'package:shared_preferences/shared_preferences.dart';
import 'local_user_storage_service.dart';
import '../features/challenges/infrastructure/services/report_challenge_service.dart';
import '../features/challenges/infrastructure/services/distance_challenge_service.dart';

/// Servicio centralizado para la limpieza completa de datos durante el logout
/// Asegura que todos los datos del usuario sean eliminados correctamente
class LogoutCleanupService {
  static final LogoutCleanupService _instance = LogoutCleanupService._internal();
  factory LogoutCleanupService() => _instance;
  LogoutCleanupService._internal();

  /// Realiza limpieza completa de todos los datos del usuario
  static Future<void> performCompleteCleanup({String? userId}) async {
    try {
      print('🧹 === INICIO DE LIMPIEZA COMPLETA DURANTE LOGOUT ===');
      
      // 1. Limpiar datos básicos del usuario
      await _clearBasicUserData();
      
      // 2. Limpiar caché específico de challenges y reportes
      await _clearChallengeData(userId);
        // 3. Limpiar datos de validaciones y otros cachés
      await _clearValidationAndCacheData(userId);
      
      // 4. Limpiar notificaciones de logros/challenges
      await _clearChallengeNotifications(userId);
      
      // 5. Limpiar datos específicos de la aplicación
      await _clearApplicationSpecificData(userId);
      
      // 5. Limpieza final de cualquier dato residual
      await _performFinalCleanup(userId);
      
      print('✅ === LIMPIEZA COMPLETA DURANTE LOGOUT FINALIZADA ===');
    } catch (e) {
      print('❌ Error durante limpieza completa: $e');
      rethrow;
    }
  }

  /// Limpia datos básicos del usuario (LocalUserStorage)
  static Future<void> _clearBasicUserData() async {
    try {
      print('🔄 Limpiando datos básicos del usuario...');
      final localUserStorage = LocalUserStorageService();
      await localUserStorage.clearUserData();
      print('✅ Datos básicos del usuario limpiados');
    } catch (e) {
      print('❌ Error limpiando datos básicos: $e');
    }
  }
  /// Limpia datos específicos de challenges y reportes
  static Future<void> _clearChallengeData(String? userId) async {
    try {
      print('🔄 Limpiando datos de challenges y reportes...');
      
      // Usar el método estático del ReportChallengeService
      await ReportChallengeService.clearAllUserDataOnLogout();
      
      // Limpiar datos de desafíos de distancia
      await DistanceChallengeService.clearAllUserDataOnLogout();
      
      print('✅ Datos de challenges y reportes limpiados');
    } catch (e) {
      print('❌ Error limpiando datos de challenges: $e');
    }
  }

  /// Limpia datos de validaciones y otros cachés específicos
  static Future<void> _clearValidationAndCacheData(String? userId) async {
    try {
      print('🔄 Limpiando datos de validaciones y cachés...');
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().toList();
      
      final validationPatterns = [
        'accessibility_validation_',
        'user_validation_',
        'form_validation_',
        'cache_validation_',
        'temp_validation_',
      ];
      
      for (final key in keys) {
        bool shouldDelete = validationPatterns.any((pattern) => 
          key.startsWith(pattern) || key.contains(pattern)
        );
        
        // Si tenemos userId, también limpiar datos específicos de ese usuario
        if (userId != null && key.contains(userId)) {
          shouldDelete = true;
        }
        
        if (shouldDelete) {
          await prefs.remove(key);
          print('🗑️ Validación eliminada: $key');
        }
      }
      
      print('✅ Datos de validaciones y cachés limpiados');
    } catch (e) {
      print('❌ Error limpiando validaciones y cachés: $e');
    }
  }

  /// Limpia todas las notificaciones de challenges/logros mostradas
  static Future<void> _clearChallengeNotifications(String? userId) async {
    try {
      print('🔄 Limpiando notificaciones de challenges/logros...');
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().toList();
      
      // Limpiar todas las claves de notificaciones de challenges
      int removedCount = 0;
      for (final key in keys) {
        if (key.startsWith('notification_shown_')) {
          // Si tenemos userId específico, solo limpiar las de ese usuario
          if (userId != null) {
            if (key.endsWith('_$userId')) {
              await prefs.remove(key);
              removedCount++;
              print('🗑️ Notificación eliminada: $key');
            }
          } else {
            // Si no hay userId específico, limpiar todas las notificaciones
            await prefs.remove(key);
            removedCount++;
            print('🗑️ Notificación eliminada: $key');
          }
        }
      }
      
      print('✅ Notificaciones de challenges limpiadas: $removedCount eliminadas');
    } catch (e) {
      print('❌ Error limpiando notificaciones de challenges: $e');
    }
  }

  /// Limpia datos específicos de la aplicación
  static Future<void> _clearApplicationSpecificData(String? userId) async {
    try {
      print('🔄 Limpiando datos específicos de la aplicación...');
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().toList();
      
      final appSpecificPatterns = [
        'user_session_',
        'user_activity_',
        'user_preferences_',
        'user_settings_',
        'user_notifications_',
        'user_badges_',
        'user_achievements_',
        'user_stats_',
        'user_history_',
        'user_favorites_',
        'last_sync_',
        'sync_timestamp_',
        'app_state_',
        'navigation_history_',
        'search_history_',
        'recent_searches_',
      ];
      
      for (final key in keys) {
        bool shouldDelete = appSpecificPatterns.any((pattern) => 
          key.startsWith(pattern) || key.contains(pattern)
        );
        
        // Si tenemos userId, también limpiar datos específicos de ese usuario
        if (userId != null && key.contains(userId)) {
          shouldDelete = true;
        }
        
        if (shouldDelete) {
          await prefs.remove(key);
          print('🗑️ Dato específico eliminado: $key');
        }
      }
      
      print('✅ Datos específicos de la aplicación limpiados');
    } catch (e) {
      print('❌ Error limpiando datos específicos de la aplicación: $e');
    }
  }

  /// Limpieza final de cualquier dato residual
  static Future<void> _performFinalCleanup(String? userId) async {
    try {
      print('🔄 Realizando limpieza final...');
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().toList();
      
      // Palabras clave que sugieren datos de usuario
      final userKeywords = [
        'user',
        'usuario',
        'profile',
        'perfil',
        'account',
        'cuenta',
        'login',
        'auth',
        'session',
        'sesion',
      ];
      
      // Solo limpiar si tenemos userId para ser más conservadores
      if (userId != null) {
        for (final key in keys) {
          bool containsUserKeyword = userKeywords.any((keyword) => 
            key.toLowerCase().contains(keyword)
          );
          
          bool containsUserId = key.contains(userId);
          
          // Solo eliminar si contiene el userId específico
          if (containsUserId && containsUserKeyword) {
            await prefs.remove(key);
            print('🗑️ Dato residual eliminado: $key');
          }
        }
      }
      
      print('✅ Limpieza final completada');
    } catch (e) {
      print('❌ Error en limpieza final: $e');
    }
  }

  /// Obtiene estadísticas de la limpieza realizada
  static Future<Map<String, int>> getCleanupStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      int totalKeys = keys.length;
      int userRelatedKeys = 0;
      int challengeKeys = 0;
      int validationKeys = 0;
      
      for (final key in keys) {
        if (key.contains('user') || key.contains('usuario')) {
          userRelatedKeys++;
        }
        if (key.contains('challenge') || key.contains('report')) {
          challengeKeys++;
        }
        if (key.contains('validation') || key.contains('cache')) {
          validationKeys++;
        }
      }
      
      return {
        'total_keys': totalKeys,
        'user_related_keys': userRelatedKeys,
        'challenge_keys': challengeKeys,
        'validation_keys': validationKeys,
      };
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return {};
    }
  }

  /// Método de verificación para asegurar que la limpieza fue exitosa
  static Future<bool> verifyCleanupSuccess(String? userId) async {
    try {
      if (userId == null) return true;
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // Verificar que no queden datos críticos del usuario
      final criticalPatterns = [
        'user_local_data',
        'current_user',
        'user_report_count_$userId',
        'challenge_completed_.*_$userId',
      ];
      
      for (final key in keys) {
        for (final pattern in criticalPatterns) {
          if (RegExp(pattern).hasMatch(key)) {
            print('⚠️ Dato crítico encontrado después de limpieza: $key');
            return false;
          }
        }
      }
      
      print('✅ Verificación de limpieza exitosa');
      return true;
    } catch (e) {
      print('❌ Error verificando limpieza: $e');
      return false;
    }
  }
}
