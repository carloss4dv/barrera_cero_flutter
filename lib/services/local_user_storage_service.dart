import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Servicio para gestionar el almacenamiento local de información del usuario
/// Funciona como el "localhost" de Flutter para datos del usuario
class LocalUserStorageService {
  static const String _userDataKey = 'user_local_data';
  static const String _userPreferencesKey = 'user_preferences';
  
  static final LocalUserStorageService _instance = LocalUserStorageService._internal();
  factory LocalUserStorageService() => _instance;
  LocalUserStorageService._internal();

  SharedPreferences? _prefs;
  /// Inicializar SharedPreferences
  Future<void> init() async {
    try {
      if (_prefs == null) {
        print('🔄 Inicializando SharedPreferences...');
        _prefs = await SharedPreferences.getInstance();
        print('✅ SharedPreferences inicializado correctamente');
      }
    } catch (e) {
      print('❌ Error inicializando SharedPreferences: $e');
      // En caso de error, intentar una vez más después de un pequeño delay
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        _prefs = await SharedPreferences.getInstance();
        print('✅ SharedPreferences inicializado en segundo intento');
      } catch (retryError) {
        print('❌ Error crítico en SharedPreferences después del reintento: $retryError');
        rethrow;
      }
    }
  }

  /// Guardar información completa del usuario localmente
  Future<bool> saveUserData({
    required String uid,
    required String email,
    required String name,
    String? displayName,
    String? mobilityType,
    List<String>? accessibilityPreferences,
    int? contributionPoints,
  }) async {
    await init();
    
    final userData = {
      'uid': uid,
      'email': email,
      'name': name,
      'displayName': displayName,
      'mobilityType': mobilityType,
      'accessibilityPreferences': accessibilityPreferences ?? [],
      'contributionPoints': contributionPoints ?? 0,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    try {
      final success = await _prefs!.setString(_userDataKey, json.encode(userData));
      if (success) {
        print('✅ Datos del usuario guardados localmente: $name ($email)');
      }
      return success;
    } catch (e) {
      print('❌ Error guardando datos del usuario: $e');
      return false;
    }
  }
  /// Obtener toda la información del usuario guardada localmente
  Future<Map<String, dynamic>?> getUserData() async {
    await init();
    
    if (_prefs == null) {
      print('❌ SharedPreferences no disponible');
      return null;
    }
    
    try {
      final userDataJson = _prefs!.getString(_userDataKey);
      if (userDataJson != null) {
        final userData = json.decode(userDataJson) as Map<String, dynamic>;
        print('✅ Datos de usuario recuperados: ${userData['email']}');
        return userData;
      } else {
        print('⚠️ No hay datos de usuario guardados');
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo datos del usuario: $e');
      // En caso de datos corruptos, intentar limpiar
      try {
        await _prefs!.remove(_userDataKey);
        print('🗑️ Datos corruptos eliminados');
      } catch (cleanError) {
        print('❌ Error limpiando datos corruptos: $cleanError');
      }
      return null;
    }
  }

  /// Obtener solo el nombre del usuario
  Future<String?> getUserName() async {
    final userData = await getUserData();
    return userData?['name'] as String?;
  }

  /// Obtener solo el email del usuario
  Future<String?> getUserEmail() async {
    final userData = await getUserData();
    return userData?['email'] as String?;
  }

  /// Obtener solo el UID del usuario
  Future<String?> getUserId() async {
    final userData = await getUserData();
    return userData?['uid'] as String?;
  }

  /// Obtener solo el displayName del usuario
  Future<String?> getUserDisplayName() async {
    final userData = await getUserData();
    return userData?['displayName'] as String?;
  }

  /// Obtener tipo de movilidad
  Future<String?> getMobilityType() async {
    final userData = await getUserData();
    return userData?['mobilityType'] as String?;
  }

  /// Obtener preferencias de accesibilidad
  Future<List<String>> getAccessibilityPreferences() async {
    final userData = await getUserData();
    final prefs = userData?['accessibilityPreferences'];
    if (prefs is List) {
      return prefs.cast<String>();
    }
    return [];
  }

  /// Obtener puntos de contribución
  Future<int> getContributionPoints() async {
    final userData = await getUserData();
    return userData?['contributionPoints'] as int? ?? 0;
  }

  /// Actualizar un campo específico
  Future<bool> updateUserField(String fieldName, dynamic value) async {
    final currentData = await getUserData();
    if (currentData != null) {
      currentData[fieldName] = value;
      currentData['lastUpdated'] = DateTime.now().toIso8601String();
      
      try {
        return await _prefs!.setString(_userDataKey, json.encode(currentData));
      } catch (e) {
        print('❌ Error actualizando campo $fieldName: $e');
        return false;
      }
    }
    return false;
  }

  /// Incrementar puntos de contribución
  Future<bool> addContributionPoints(int points) async {
    final currentPoints = await getContributionPoints();
    return await updateUserField('contributionPoints', currentPoints + points);
  }

  /// Verificar si hay datos de usuario guardados
  Future<bool> hasUserData() async {
    await init();
    return _prefs!.containsKey(_userDataKey);
  }

  /// Obtener información resumida del usuario para mostrar en UI
  Future<String> getUserDisplayInfo() async {
    final name = await getUserName();
    final email = await getUserEmail();
    
    if (name != null && name.isNotEmpty) {
      return name;
    } else if (email != null) {
      return email.split('@').first; // Usar la parte antes del @ como nombre
    } else {
      return 'Usuario';
    }
  }
  /// Limpiar todos los datos del usuario
  Future<bool> clearUserData() async {
    await init();
    try {
      print('🔄 Iniciando limpieza completa de datos del usuario...');
      
      // Limpiar claves principales de datos del usuario
      await _prefs!.remove(_userDataKey);
      await _prefs!.remove(_userPreferencesKey);
      print('✅ Datos principales del usuario eliminados');
      
      // Limpiar datos específicos adicionales del usuario
      await _clearUserSpecificCache();
      
      print('🗑️ Limpieza completa de datos locales del usuario finalizada');
      return true;
    } catch (e) {
      print('❌ Error limpiando datos del usuario: $e');
      return false;
    }
  }

  /// Limpia datos específicos del usuario que podrían quedar en SharedPreferences
  Future<void> _clearUserSpecificCache() async {
    try {
      if (_prefs != null) {
        final keys = _prefs!.getKeys().toList();
        
        // Obtener el UID del usuario actual si está disponible
        final userData = await getUserData();
        final currentUserId = userData?['uid'] as String?;
        
        // Lista de patrones de claves que deben ser limpiadas
        final userDataPatterns = [
          'user_validation_',
          'accessibility_validation_',
          'user_cache_',
          'user_settings_',
          'user_notifications_',
          'user_temp_',
          'last_sync_',
          'user_session_',
          'user_activity_',
        ];
        
        for (final key in keys) {
          bool shouldDelete = false;
          
          // Verificar patrones generales
          shouldDelete = userDataPatterns.any((pattern) => 
            key.startsWith(pattern) || key.contains(pattern)
          );
          
          // Si tenemos el UID del usuario, también limpiar datos específicos de ese usuario
          if (currentUserId != null && key.contains(currentUserId)) {
            shouldDelete = true;
          }
          
          if (shouldDelete) {
            await _prefs!.remove(key);
            print('🗑️ Clave específica eliminada: $key');
          }
        }
        
        print('✅ Limpieza de datos específicos del usuario completada');
      }
    } catch (e) {
      print('❌ Error limpiando datos específicos del usuario: $e');
    }
  }

  /// Sincronizar datos con Firebase (llamar después de cambios en Firestore)
  Future<bool> syncWithFirestore(Map<String, dynamic> firestoreData) async {
    return await saveUserData(
      uid: firestoreData['id'] ?? firestoreData['uid'],
      email: firestoreData['email'],
      name: firestoreData['name'],
      displayName: firestoreData['displayName'],
      mobilityType: firestoreData['mobilityType'],
      accessibilityPreferences: (firestoreData['accessibilityPreferences'] as List?)?.cast<String>(),
      contributionPoints: firestoreData['contributionPoints'],
    );
  }

  /// Obtener información de depuración
  Future<void> printDebugInfo() async {
    final userData = await getUserData();
    print('🔍 Información local del usuario:');
    if (userData != null) {
      userData.forEach((key, value) {
        print('  $key: $value');
      });
    } else {
      print('  No hay datos guardados');
    }
  }
}

/// Instancia global del servicio
final localUserStorage = LocalUserStorageService();
