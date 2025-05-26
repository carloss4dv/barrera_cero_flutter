import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Fixed import
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../users/services/user_service.dart';
import '../../../services/local_user_storage_service.dart';

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
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      _auth.authStateChanges().listen((User? user) {
        if (_isInitialized && _prefs != null) {
          _saveUserToPrefs(user);
          notifyListeners();
        }
      });
    } catch (e) {
      print('Error initializing SharedPreferences: $e');
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
      await _auth.signOut();
      if (_prefs != null) {
        await _prefs!.remove(_userKey);
      }
      await localUserStorage.clearUserData();
      notifyListeners();
    } catch (e) {
      print('Error during sign out: $e');
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
  }

  Future<void> _saveUserToPrefs(User? user) async {
    if (_prefs == null) return;
    
    if (user == null) {
      await _prefs!.remove(_userKey);
      await localUserStorage.clearUserData();
    } else {
      try {
        // Obtener información adicional del usuario desde Firestore
        final firestoreUser = await _userService.getUserById(user.uid);
        
        final userData = {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'name': firestoreUser?.name ?? user.displayName ?? user.email?.split('@').first ?? 'Usuario',
        };
        await _prefs!.setString(_userKey, json.encode(userData));
        
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
        } else {
          // Si no hay datos en Firestore, guardar datos básicos
          await localUserStorage.saveUserData(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? user.email?.split('@').first ?? 'Usuario',
            displayName: user.displayName,
          );
        }
        
      } catch (e) {
        // Si hay error al obtener datos de Firestore, guardar solo los datos básicos
        print('Error obteniendo datos de Firestore: $e');
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
      }
    }
  }

  Future<UserCredential> signIn(
     String email,
     String password,
  ) async {
    try {
      // Configura la persistencia antes de iniciar sesión
      await _auth.setPersistence(Persistence.LOCAL);
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserToPrefs(credential.user);
      notifyListeners();
      return credential;
    } catch (e) {
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
