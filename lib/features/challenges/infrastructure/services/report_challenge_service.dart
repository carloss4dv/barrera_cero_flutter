import '../../../users/services/user_service.dart';
import '../../domain/challenge_model.dart';
import '../../../../services/local_user_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportChallengeService {
  final UserService _userService;
  final FirebaseFirestore _firestore;
  
  // Callback para notificar cuando se completa un desafío
  Function(Challenge challenge, int pointsAwarded)? onChallengeCompleted;

  ReportChallengeService(this._userService)
      : _firestore = FirebaseFirestore.instance;/// Obtiene el número de reportes hechos por el usuario actual
  /// Realiza una consulta a Firebase directamente y guarda en SharedPreferences
  Future<int> getUserReportCount() async {
    try {
      // Obtener el UID del usuario autenticado
      final localUserStorage = LocalUserStorageService();
      await localUserStorage.init();
      final currentUserId = await localUserStorage.getUserId();
      
      if (currentUserId == null) {
        print('=== DEBUG: No se pudo obtener el UID del usuario actual ===');
        return 0;
      }

      print('=== DEBUG: Consultando reportes para usuario UID: $currentUserId ===');
      
      // Primero intentar cargar desde SharedPreferences (cache)
      final cachedCount = await _getCachedReportCount(currentUserId);
      if (cachedCount != null) {
        print('=== DEBUG: Usando conteo cacheado: $cachedCount ===');
        // Actualizar en background y devolver el valor cacheado
        _updateReportCountFromFirebase(currentUserId);
        return cachedCount;
      }
      
      // Si no hay cache, consultar Firebase directamente
      return await _updateReportCountFromFirebase(currentUserId);
      
    } catch (e) {
      print('ERROR: Error obteniendo conteo de reportes del usuario: $e');
      return 0;
    }
  }

  /// Consulta Firebase para obtener todos los reportes del usuario
  Future<int> _updateReportCountFromFirebase(String userId) async {
    try {
      int totalReports = 0;
      
      // Consultar la colección 'places' para encontrar todos los reportes del usuario
      final placesSnapshot = await _firestore.collection('places').get();
      
      print('=== DEBUG: Consultando ${placesSnapshot.docs.length} lugares ===');
      
      for (final placeDoc in placesSnapshot.docs) {
        final reportsSnapshot = await placeDoc.reference
            .collection('accessibility_reports')
            .where('user_id', isEqualTo: userId)
            .get();
        
        if (reportsSnapshot.docs.isNotEmpty) {
          totalReports += reportsSnapshot.docs.length;
          print('=== DEBUG: Encontrados ${reportsSnapshot.docs.length} reportes en ${placeDoc.id} ===');
        }
      }
      
      print('=== DEBUG: Total de reportes encontrados para $userId: $totalReports ===');
      
      // Guardar en SharedPreferences
      await _cacheReportCount(userId, totalReports);
      
      return totalReports;
      
    } catch (e) {
      print('ERROR: Error consultando Firebase: $e');
      return 0;
    }
  }

  /// Obtiene el conteo cacheado desde SharedPreferences
  Future<int?> _getCachedReportCount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'user_report_count_$userId';
      final cachedValue = prefs.getInt(key);
      
      if (cachedValue != null) {
        // Verificar si el cache no es muy viejo (15 minutos)
        final timestampKey = 'user_report_count_timestamp_$userId';
        final timestamp = prefs.getInt(timestampKey) ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        if (now - timestamp < 900000) { // 15 minutos en milisegundos
          return cachedValue;
        }
      }
      
      return null;
    } catch (e) {
      print('ERROR: Error obteniendo cache: $e');
      return null;
    }
  }

  /// Guarda el conteo en SharedPreferences
  Future<void> _cacheReportCount(String userId, int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'user_report_count_$userId';
      final timestampKey = 'user_report_count_timestamp_$userId';
      
      await prefs.setInt(key, count);
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
      
      print('=== DEBUG: Conteo guardado en cache: $count ===');
    } catch (e) {
      print('ERROR: Error guardando en cache: $e');
    }
  }
  /// Limpia el cache cuando se agrega un nuevo reporte
  Future<void> clearReportCountCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'user_report_count_$userId';
      final timestampKey = 'user_report_count_timestamp_$userId';
      
      await prefs.remove(key);
      await prefs.remove(timestampKey);
      
      print('=== DEBUG: Cache de reportes limpiado para usuario $userId ===');
    } catch (e) {
      print('ERROR: Error limpiando cache: $e');
    }
  }

  /// Verifica si un desafío ya fue completado previamente
  Future<bool> _wasAlreadyCompleted(String challengeId, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'challenge_completed_${challengeId}_$userId';
      return prefs.getBool(key) ?? false;
    } catch (e) {
      print('ERROR: Error verificando estado del desafío: $e');
      return false;
    }
  }

  /// Marca un desafío como completado
  Future<void> _markChallengeAsCompleted(String challengeId, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'challenge_completed_${challengeId}_$userId';
      await prefs.setBool(key, true);
      print('=== DEBUG: Desafío $challengeId marcado como completado para usuario $userId ===');
    } catch (e) {
      print('ERROR: Error marcando desafío como completado: $e');
    }
  }

  /// Método estático para limpiar cache desde cualquier lugar de la aplicación
  static Future<void> clearCacheForCurrentUser() async {
    try {
      final localUserStorage = LocalUserStorageService();
      await localUserStorage.init();
      final currentUserId = await localUserStorage.getUserId();
      
      if (currentUserId != null) {
        final prefs = await SharedPreferences.getInstance();
        final key = 'user_report_count_$currentUserId';
        final timestampKey = 'user_report_count_timestamp_$currentUserId';
        
        await prefs.remove(key);
        await prefs.remove(timestampKey);
        
        print('=== DEBUG: Cache limpiado para usuario actual: $currentUserId ===');
      }
    } catch (e) {
      print('ERROR: Error limpiando cache del usuario actual: $e');
    }
  }

  /// Verifica si un desafío de reportes ha sido completado
  Future<bool> isChallengeCompleted(Challenge challenge) async {
    if (challenge.type != ChallengeType.reports) return challenge.isCompleted;
    
    final reportCount = await getUserReportCount();
    return reportCount >= challenge.target;
  }  /// Actualiza el progreso de un desafío de reportes
  Future<Challenge> updateChallengeProgress(Challenge challenge) async {
    print('=== DEBUG: ReportChallengeService.updateChallengeProgress() - INICIANDO para: ${challenge.title} ===');
    
    if (challenge.type != ChallengeType.reports) {
      print('=== DEBUG: El desafío no es de tipo reportes, retornando sin cambios ===');
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
    
    print('=== DEBUG: Obteniendo conteo de reportes del usuario... ===');
    final reportCount = await getUserReportCount();
    final isCompleted = reportCount >= challenge.target;
    
    // Verificar si ya había sido completado antes
    final wasAlreadyCompleted = await _wasAlreadyCompleted(challenge.id, currentUserId);
    
    print('=== DEBUG: Reportes del usuario: $reportCount, Target: ${challenge.target}, Completado: $isCompleted, Ya completado antes: $wasAlreadyCompleted ===');    // Si el desafío se completa por primera vez, otorgar puntos
    if (isCompleted && !wasAlreadyCompleted) {
      print('=== DEBUG: ¡Desafío completado por primera vez! Otorgando ${challenge.points} B-points ===');
      try {
        await _userService.addBPoints(challenge.points);
        await _markChallengeAsCompleted(challenge.id, currentUserId);
        print('=== DEBUG: B-points otorgados exitosamente y desafío marcado como completado ===');
        
        // Notificar a la UI sobre la completación del desafío
        onChallengeCompleted?.call(challenge, challenge.points);
        
      } catch (e) {
        print('=== ERROR: Error otorgando B-points: $e ===');
      }
    }

    return challenge.copyWith(
      currentProgress: reportCount,
      isCompleted: isCompleted,
    );
  }

  /// Verifica si un desafío acaba de ser completado (para otorgar puntos)
  Future<bool> wasJustCompleted(Challenge challenge) async {
    if (challenge.type != ChallengeType.reports) return false;
    if (challenge.isCompleted) return false; // Ya estaba completado
    
    final reportCount = await getUserReportCount();
    return reportCount >= challenge.target;
  }

  /// Otorga puntos B-points por completar un desafío
  Future<void> awardChallengePoints(Challenge challenge) async {
    final currentUser = await _userService.getCurrentUser();
    if (currentUser == null) return;

    await _userService.addBPoints(challenge.points);
  }
}
