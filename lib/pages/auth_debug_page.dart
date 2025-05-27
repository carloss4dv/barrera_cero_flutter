import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../features/auth/service/auth_service.dart';
import '../services/local_user_storage_service.dart';
import '../widgets/loading_card.dart';

class AuthDebugPage extends StatefulWidget {
  const AuthDebugPage({Key? key}) : super(key: key);
  
  @override
  State<AuthDebugPage> createState() => _AuthDebugPageState();
}

class _AuthDebugPageState extends State<AuthDebugPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _debugOutput = '';
  bool _isRunning = false;
  
  @override
  void initState() {
    super.initState();
    _runInitialDiagnostic();
  }
  
  void _addToOutput(String message) {
    setState(() {
      _debugOutput += '${DateTime.now().toString().substring(11, 19)} - $message\n';
    });
    print(message);
  }
  
  Future<void> _runInitialDiagnostic() async {
    _addToOutput('🔍 === DIAGNÓSTICO INICIAL ===');
    
    // Verificar Firebase Auth
    try {
      final auth = FirebaseAuth.instance;
      _addToOutput('✅ Firebase Auth disponible');
      _addToOutput('📧 Usuario actual: ${auth.currentUser?.email ?? "No hay usuario"}');
    } catch (e) {
      _addToOutput('❌ Error Firebase Auth: $e');
    }
    
    // Verificar SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      _addToOutput('✅ SharedPreferences disponible');
      _addToOutput('🗝️ Claves totales: ${keys.length}');
      
      if (keys.contains('current_user')) {
        final userData = prefs.getString('current_user');
        _addToOutput('👤 Datos legacy encontrados: ${userData != null ? "Sí" : "No"}');
      }
      
      if (keys.contains('user_local_data')) {
        final userData = prefs.getString('user_local_data');
        _addToOutput('💾 Datos locales encontrados: ${userData != null ? "Sí" : "No"}');
      }
    } catch (e) {
      _addToOutput('❌ Error SharedPreferences: $e');
    }
    
    // Verificar LocalUserStorage
    try {
      final storage = LocalUserStorageService();
      await storage.init();
      final hasData = await storage.hasUserData();
      _addToOutput('🏠 LocalUserStorage: ${hasData ? "Con datos" : "Sin datos"}');
    } catch (e) {
      _addToOutput('❌ Error LocalUserStorage: $e');
    }
    
    _addToOutput('✅ Diagnóstico inicial completado');
  }
  
  Future<void> _testLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _addToOutput('❌ Email y contraseña requeridos');
      return;
    }
    
    setState(() => _isRunning = true);
    
    _addToOutput('🧪 === PRUEBA DE LOGIN ===');
    _addToOutput('📧 Email: ${_emailController.text}');
    
    try {
      final authService = AuthService();
      
      _addToOutput('1️⃣ Iniciando proceso de login...');
      
      final credential = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      _addToOutput('✅ Login exitoso!');
      _addToOutput('👤 Usuario: ${credential.user?.email}');
      _addToOutput('🆔 UID: ${credential.user?.uid}');
      
      // Verificar que los datos se guardaron correctamente
      await Future.delayed(const Duration(milliseconds: 1000));
      
      _addToOutput('2️⃣ Verificando datos guardados...');
      
      // Verificar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('current_user');
      if (savedData != null) {
        try {
          final userData = json.decode(savedData);
          _addToOutput('✅ Datos en SharedPreferences: ${userData['email']}');
        } catch (e) {
          _addToOutput('❌ Error decodificando SharedPreferences: $e');
        }
      } else {
        _addToOutput('⚠️ No hay datos en SharedPreferences');
      }
      
      // Verificar LocalUserStorage
      final storage = LocalUserStorageService();
      final userData = await storage.getUserData();
      if (userData != null) {
        _addToOutput('✅ Datos en LocalUserStorage: ${userData['email']}');
      } else {
        _addToOutput('⚠️ No hay datos en LocalUserStorage');
      }
      
      _addToOutput('🎉 Verificación completa!');
      
    } catch (e) {
      _addToOutput('❌ Error en login: $e');
      if (e is FirebaseAuthException) {
        _addToOutput('🔥 Código Firebase: ${e.code}');
        _addToOutput('📝 Mensaje: ${e.message}');
        
        // Sugerencias específicas por tipo de error
        switch (e.code) {
          case 'user-not-found':
            _addToOutput('💡 El usuario no existe. Verifica el email.');
            break;
          case 'wrong-password':
            _addToOutput('💡 Contraseña incorrecta.');
            break;
          case 'invalid-email':
            _addToOutput('💡 Email inválido.');
            break;
          case 'user-disabled':
            _addToOutput('💡 La cuenta está deshabilitada.');
            break;
          case 'too-many-requests':
            _addToOutput('💡 Demasiados intentos. Espera un momento.');
            break;
          case 'network-request-failed':
            _addToOutput('💡 Sin conexión a internet.');
            break;
          default:
            _addToOutput('💡 Error desconocido. Verifica la configuración.');
        }
      }
    } finally {
      setState(() => _isRunning = false);
    }
  }
  
  Future<void> _cleanAllData() async {
    setState(() => _isRunning = true);
    
    _addToOutput('🧹 === LIMPIEZA DE DATOS ===');
    
    try {
      // Cerrar sesión de Firebase
      await FirebaseAuth.instance.signOut();
      _addToOutput('✅ Sesión Firebase cerrada');
      
      // Limpiar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      await prefs.remove('user_local_data');
      _addToOutput('✅ SharedPreferences limpiado');
      
      // Limpiar LocalUserStorage
      final storage = LocalUserStorageService();
      await storage.clearUserData();
      _addToOutput('✅ LocalUserStorage limpiado');
      
      _addToOutput('🎉 Limpieza completada');
      
      // Ejecutar diagnóstico nuevamente
      await Future.delayed(const Duration(milliseconds: 500));
      await _runInitialDiagnostic();
      
    } catch (e) {
      _addToOutput('❌ Error durante limpieza: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }
  
  Future<void> _checkCurrentSession() async {
    _addToOutput('🔍 === VERIFICACIÓN DE SESIÓN ===');
    
    try {
      final authService = AuthService();
      final hasSession = await authService.checkSession();
      _addToOutput('📱 Sesión guardada: ${hasSession ? "Sí" : "No"}');
      
      final currentUser = authService.currentUser;
      if (currentUser != null) {
        _addToOutput('👤 Usuario actual: ${currentUser.email}');
        _addToOutput('🆔 UID: ${currentUser.uid}');
      } else {
        _addToOutput('⚠️ No hay usuario autenticado');
      }
      
      // Verificar datos en almacenamiento
      final userData = await authService.getUserFromPrefs();
      if (userData != null) {
        _addToOutput('💾 Datos en prefs: ${userData['email']}');
      } else {
        _addToOutput('⚠️ No hay datos en preferences');
      }
      
    } catch (e) {
      _addToOutput('❌ Error verificando sesión: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Autenticación'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de información
            Card(
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        const Text(
                          'Herramienta de Diagnóstico',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Esta herramienta te ayuda a diagnosticar problemas de autenticación en Android. '
                      'Usa las funciones de abajo para probar y solucionar problemas.',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Formulario de login para pruebas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prueba de Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botones de acción
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _testLogin,
                  icon: const Icon(Icons.login),
                  label: const Text('Probar Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _checkCurrentSession,
                  icon: const Icon(Icons.person_search),
                  label: const Text('Verificar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _cleanAllData,
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text('Limpiar Todo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _debugOutput = ''),
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar Log'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Output del debug
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.terminal, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'Log de Diagnóstico',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),                          if (_isRunning)
                            const LoadingIndicator(size: 16),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _debugOutput.isEmpty 
                              ? 'El diagnóstico aparecerá aquí...' 
                              : _debugOutput,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
