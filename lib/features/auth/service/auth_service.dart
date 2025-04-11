import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Fixed import
import 'dart:convert';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  Future<void> _saveUserToPrefs(User? user) async {
    if (_prefs == null) return;
    
    if (user == null) {
      await _prefs!.remove(_userKey);
    } else {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
      };
      await _prefs!.setString(_userKey, json.encode(userData));
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
