import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/foundation.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(
     String email,
     String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email, password: password);
  }

  Future<UserCredential> createAccount(
     String email,
     String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
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
