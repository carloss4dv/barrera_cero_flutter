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
    _prefs ??= await SharedPreferences.getInstance();
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
    
    try {
      final userDataJson = _prefs!.getString(_userDataKey);
      if (userDataJson != null) {
        return json.decode(userDataJson) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Error obteniendo datos del usuario: $e');
    }
    
    return null;
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
      await _prefs!.remove(_userDataKey);
      await _prefs!.remove(_userPreferencesKey);
      print('🗑️ Datos locales del usuario eliminados');
      return true;
    } catch (e) {
      print('❌ Error limpiando datos del usuario: $e');
      return false;
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
