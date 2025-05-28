import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Fixed import
import 'dart:convert';
import '../../users/services/user_service.dart';
import '../../../services/local_user_storage_service.dart';
import '../../../services/logout_cleanup_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  SharedPreferences? _prefs;
  static const String _userKey = 'current_user';
  bool _isInitialized = false;
  
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  AuthService._internal() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      print('🔄 Inicializando AuthService...');
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      print('✅ SharedPreferences inicializado correctamente');
      
      // Inicializar también el LocalUserStorage
      final localStorage = LocalUserStorageService();
      await localStorage.init();
      print('✅ LocalUserStorage inicializado correctamente');
      
      _auth.authStateChanges().listen((User? user) {
        if (_isInitialized && _prefs != null) {
          print('🔄 Estado de autenticación cambió: ${user?.email ?? "sin usuario"}');
          _saveUserToPrefs(user);
          notifyListeners();
        }
      });
      print('✅ Listener de estado de autenticación configurado');
    } catch (e) {
      print('❌ Error inicializando AuthService: $e');
      _isInitialized = false;
    }
  }

  Future<void> initPrefs() async {
    if (!_isInitialized || _prefs == null) {
      await _initialize();
    }
    if (_prefs != null) {
      final savedUserJson = _prefs!.getString(_userKey);
      if (savedUserJson != null && _auth.currentUser == null) {
        await _prefs!.remove(_userKey);
      }
    }
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signOut() async {
    try {
      print('🔄 Iniciando proceso de logout completo...');
      
      // Obtener el UID del usuario actual antes de cerrar sesión
      final currentUserId = currentUser?.uid;
      
      // 1. Cerrar sesión de Firebase
      await _auth.signOut();
      print('✅ Sesión Firebase cerrada');
      
      // 2. Realizar limpieza completa usando el servicio centralizado
      await LogoutCleanupService.performCompleteCleanup(userId: currentUserId);
      
      // 3. Limpieza adicional de SharedPreferences básico (por seguridad)
      if (_prefs != null) {
        await _prefs!.remove(_userKey);
        print('✅ Limpieza adicional de datos básicos completada');
      }
      
      // 4. Verificar que la limpieza fue exitosa
      final cleanupSuccess = await LogoutCleanupService.verifyCleanupSuccess(currentUserId);
      if (cleanupSuccess) {
        print('✅ Verificación de limpieza exitosa');
      } else {
        print('⚠️ Advertencia: Algunos datos pueden no haberse limpiado completamente');
      }
      
      print('🎉 Logout completo finalizado exitosamente');
      notifyListeners();
    } catch (e) {
      print('❌ Error durante el logout: $e');
      rethrow;
    }
  }



  Future<bool> checkSession() async {
    if (_prefs == null) return false;
    final savedUserJson = _prefs!.getString(_userKey);
    return savedUserJson != null && _auth.currentUser != null;
  }

  String? get currentUserId => currentUser?.uid;

  // Métodos para obtener información del usuario desde SharedPreferences
  Future<Map<String, dynamic>?> getUserFromPrefs() async {
    if (_prefs == null) return null;
    final savedUserJson = _prefs!.getString(_userKey);
    if (savedUserJson != null) {
      try {
        return json.decode(savedUserJson) as Map<String, dynamic>;
      } catch (e) {
        print('Error decodificando datos del usuario: $e');
        return null;
      }
    }
    return null;
  }

  Future<String?> getUserNameFromPrefs() async {
    final userData = await getUserFromPrefs();
    return userData?['name'] as String?;
  }

  Future<String?> getUserEmailFromPrefs() async {
    final userData = await getUserFromPrefs();
    return userData?['email'] as String?;
  }

  Future<String?> getUserDisplayNameFromPrefs() async {
    final userData = await getUserFromPrefs();
    return userData?['displayName'] as String?;
  }  Future<void> _saveUserToPrefs(User? user) async {
    if (_prefs == null) {
      print('⚠️ SharedPreferences no inicializado, intentando inicializar...');
      await _initialize();
      if (_prefs == null) {
        print('❌ No se pudo inicializar SharedPreferences');
        return;
      }
    }
    
    if (user == null) {
      try {
        await _prefs!.remove(_userKey);
        await localUserStorage.clearUserData();
        print('🗑️ Datos de usuario eliminados');
      } catch (e) {
        print('❌ Error eliminando datos de usuario: $e');
      }
    } else {
      try {
        print('💾 Guardando datos de usuario: ${user.email}');
        
        // Obtener información adicional del usuario desde Firestore
        final firestoreUser = await _userService.getUserById(user.uid);
        
        final userData = {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'name': firestoreUser?.name ?? user.displayName ?? user.email?.split('@').first ?? 'Usuario',
        };
        
        // Guardar en SharedPreferences legacy
        await _prefs!.setString(_userKey, json.encode(userData));
        print('✅ Datos guardados en SharedPreferences');
        
        // Guardar información completa en el nuevo servicio de almacenamiento local
        if (firestoreUser != null) {
          await localUserStorage.saveUserData(
            uid: user.uid,
            email: user.email ?? '',
            name: firestoreUser.name,
            displayName: user.displayName,
            mobilityType: firestoreUser.mobilityType.toString().split('.').last,
            accessibilityPreferences: firestoreUser.accessibilityPreferences
                .map((pref) => pref.toString().split('.').last)
                .toList(),
            contributionPoints: firestoreUser.contributionPoints,
          );
          print('✅ Datos completos guardados en LocalUserStorage');
        } else {
          // Si no hay datos en Firestore, guardar datos básicos
          await localUserStorage.saveUserData(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? user.email?.split('@').first ?? 'Usuario',
            displayName: user.displayName,
          );
          print('✅ Datos básicos guardados en LocalUserStorage');
        }
        
      } catch (e) {
        print('❌ Error obteniendo/guardando datos de Firestore: $e');
        // Si hay error al obtener datos de Firestore, guardar solo los datos básicos
        try {
          final userData = {
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'name': user.displayName ?? user.email?.split('@').first ?? 'Usuario',
          };
          await _prefs!.setString(_userKey, json.encode(userData));
          
          // Guardar datos básicos en el nuevo servicio
          await localUserStorage.saveUserData(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? user.email?.split('@').first ?? 'Usuario',
            displayName: user.displayName,
          );
          print('✅ Datos básicos guardados después del error');
        } catch (saveError) {
          print('❌ Error crítico guardando datos básicos: $saveError');
        }
      }
    }
  }

  Future<UserCredential> signIn(
     String email,
     String password,
  ) async {
    try {
      // En Android, la persistencia se maneja automáticamente
      // Solo configurar persistencia en web
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);
      }
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Asegurarse de que _prefs esté inicializado antes de guardar
      if (!_isInitialized || _prefs == null) {
        await _initialize();
      }
      
      await _saveUserToPrefs(credential.user);
      notifyListeners();
      return credential;
    } catch (e) {
      print('❌ Error en signIn: $e');
      if (e is FirebaseAuthException) {
        print('🔥 Firebase Auth Error - Code: ${e.code}, Message: ${e.message}');
      }
      rethrow;
    }
  }

  Future<UserCredential> createAccount(
     String email,
     String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email, password: password);
  }

  Future<void> sendPasswordResetEmail(
     String email,
  ) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername(
     String username,
  ) async {
    await _auth.currentUser?.updateDisplayName(username);
  }

  Future<void> deleteAccount(
     String password,
     String email,
  ) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await _auth.currentUser?.reauthenticateWithCredential(credential);
    await _auth.currentUser?.delete();
    await _auth.signOut();
  }

  Future<void> resetPasswordFromCurrentPassword(
     String password,
     String newPassword,
     String email,
  ) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await _auth.currentUser?.reauthenticateWithCredential(credential);
    await _auth.currentUser?.updatePassword(newPassword);
  }
}

// Global instance
final authService = AuthService();
