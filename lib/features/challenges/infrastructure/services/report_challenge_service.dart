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
      : _firestore = FirebaseFirestore.instance;  /// Obtiene el número de reportes hechos por el usuario actual
  /// Usa caché inteligente: busca en DB al iniciar sesión, luego usa caché
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
      
      // Verificar si es la primera consulta de la sesión
      final isFirstSessionQuery = await _isFirstSessionQuery(currentUserId);
      
      if (isFirstSessionQuery) {
        print('=== DEBUG: Primera consulta de la sesión - Consultando base de datos ===');
        // Primera consulta de la sesión: ir directamente a Firebase
        final count = await _updateReportCountFromFirebase(currentUserId);
        await _markSessionAsInitialized(currentUserId);
        return count;
      } else {
        print('=== DEBUG: Sesión ya inicializada - Usando caché ===');
        // Sesión ya inicializada: usar caché
        final cachedCount = await _getCachedReportCount(currentUserId);
        if (cachedCount != null) {
          print('=== DEBUG: Usando conteo cacheado: $cachedCount ===');
          return cachedCount;
        } else {
          // Si por alguna razón no hay caché, consultar Firebase
          print('=== DEBUG: No hay caché disponible - Consultando Firebase ===');
          return await _updateReportCountFromFirebase(currentUserId);
        }
      }
      
    } catch (e) {
      print('ERROR: Error obteniendo conteo de reportes del usuario: $e');
      return 0;
    }
  }

  /// Consulta Firebase para obtener todos los reportes del usuario
  Future<int> _updateReportCountFromFirebase(String userId) async {
    try {
      int totalReports = 0;
      
      // Consulta global a todos los subcollections 'accessibility_reports' bajo 'places'
      final reportsSnapshot = await _firestore
        .collectionGroup('accessibility_reports')
        .where('user_id', isEqualTo: userId)
        .get();

      totalReports = reportsSnapshot.docs.length;
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
  /// Verifica si es la primera consulta de la sesión
  Future<bool> _isFirstSessionQuery(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = 'session_initialized_$userId';
      return !(prefs.getBool(sessionKey) ?? false);
    } catch (e) {
      print('ERROR: Error verificando inicialización de sesión: $e');
      return true; // En caso de error, asumir que es primera consulta
    }
  }

  /// Marca la sesión como inicializada
  Future<void> _markSessionAsInitialized(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = 'session_initialized_$userId';
      await prefs.setBool(sessionKey, true);
      print('=== DEBUG: Sesión marcada como inicializada para usuario $userId ===');
    } catch (e) {
      print('ERROR: Error marcando sesión como inicializada: $e');
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
  /// Actualiza inteligentemente el cache para el usuario actual
  static Future<void> smartUpdateCacheForCurrentUser() async {
    try {
      final localUserStorage = LocalUserStorageService();
      await localUserStorage.init();
      final currentUserId = await localUserStorage.getUserId();
      
      if (currentUserId != null) {
        print('=== DEBUG: Actualizando cache inteligentemente para usuario: $currentUserId ===');
        
        // Al crear un nuevo reporte, incrementar el cache en lugar de limpiarlo
        final prefs = await SharedPreferences.getInstance();
        final key = 'user_report_count_$currentUserId';
        final currentCachedCount = prefs.getInt(key) ?? 0;
        
        // Incrementar el contador en 1 (porque se acaba de agregar un reporte)
        final newCount = currentCachedCount + 1;
        
        // Actualizar el cache con el nuevo valor
        await prefs.setInt(key, newCount);
        await prefs.setInt('user_report_count_timestamp_$currentUserId', DateTime.now().millisecondsSinceEpoch);
        
        print('=== DEBUG: Cache actualizado: $currentCachedCount -> $newCount ===');
      }
    } catch (e) {
      print('ERROR: Error en actualización inteligente de cache: $e');
    }
  }
  /// Limpia todos los datos del usuario en logout
  static Future<void> clearAllUserDataOnLogout() async {
    try {
      print('🔄 Limpiando todos los datos de challenges y reportes en logout...');
      
      final localUserStorage = LocalUserStorageService();
      await localUserStorage.init();
      final currentUserId = await localUserStorage.getUserId();
      
      if (currentUserId != null) {
        final prefs = await SharedPreferences.getInstance();
        
        // Limpiar cache de reportes
        final reportCountKey = 'user_report_count_$currentUserId';
        final timestampKey = 'user_report_count_timestamp_$currentUserId';
        await prefs.remove(reportCountKey);
        await prefs.remove(timestampKey);
        
        // Limpiar marca de sesión inicializada
        final sessionKey = 'session_initialized_$currentUserId';
        await prefs.remove(sessionKey);
        
        // Limpiar estado de challenges completados
        final keys = prefs.getKeys();
        final challengeKeys = keys.where((key) => 
          key.startsWith('challenge_completed_') && key.endsWith('_$currentUserId')
        ).toList();
        
        for (final key in challengeKeys) {
          await prefs.remove(key);
        }
        
        print('✅ Todos los datos de challenges y reportes limpiados para usuario: $currentUserId');
      }
    } catch (e) {
      print('❌ Error limpiando datos de challenges en logout: $e');
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
