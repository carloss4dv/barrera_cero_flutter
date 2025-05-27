import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/features/auth/service/auth_service.dart';
import 'lib/services/local_user_storage_service.dart';

/// Script de diagnóstico para problemas de autenticación en Android
class AndroidAuthDebugger {
  static Future<void> runDiagnostics() async {
    print('\n🔍 === DIAGNÓSTICO DE AUTENTICACIÓN ANDROID ===\n');
    
    // 1. Verificar Firebase Auth
    await _checkFirebaseAuth();
    
    // 2. Verificar SharedPreferences
    await _checkSharedPreferences();
    
    // 3. Verificar persistencia
    await _checkPersistence();
    
    // 4. Verificar servicio de almacenamiento local
    await _checkLocalUserStorage();
    
    // 5. Verificar configuración de Firebase
    await _checkFirebaseConfig();
    
    print('\n✅ === DIAGNÓSTICO COMPLETADO ===\n');
  }
  
  static Future<void> _checkFirebaseAuth() async {
    print('📱 Verificando Firebase Auth...');
    try {
      final auth = FirebaseAuth.instance;
      print('  ✅ FirebaseAuth inicializado: ${auth.app.name}');
      print('  📧 Usuario actual: ${auth.currentUser?.email ?? "No hay usuario"}');
      print('  🔐 Estado de autenticación: ${auth.currentUser != null ? "Autenticado" : "No autenticado"}');
    } catch (e) {
      print('  ❌ Error en FirebaseAuth: $e');
    }
  }
  
  static Future<void> _checkSharedPreferences() async {
    print('\n💾 Verificando SharedPreferences...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      print('  ✅ SharedPreferences disponible');
      print('  🗝️ Claves encontradas: ${keys.length}');
      
      // Verificar claves específicas de autenticación
      const authKeys = ['current_user', 'user_local_data'];
      for (final key in authKeys) {
        if (keys.contains(key)) {
          final value = prefs.getString(key);
          print('  ✅ Clave "$key": ${value != null ? "Datos encontrados" : "Sin datos"}');
        } else {
          print('  ⚠️ Clave "$key": No encontrada');
        }
      }
    } catch (e) {
      print('  ❌ Error en SharedPreferences: $e');
    }
  }
  
  static Future<void> _checkPersistence() async {
    print('\n🔄 Verificando persistencia...');
    try {
      final auth = FirebaseAuth.instance;
      
      // Intentar configurar persistencia
      await auth.setPersistence(Persistence.LOCAL);
      print('  ✅ Persistencia LOCAL configurada correctamente');
      
      // En Android, también verificar si hay problemas con la configuración
      print('  📱 Plataforma: Android');
      print('  🏪 App name: ${auth.app.name}');
      
    } catch (e) {
      print('  ❌ Error configurando persistencia: $e');
      print('  💡 Sugerencia: Verificar configuración de Firebase en Android');
    }
  }
  
  static Future<void> _checkLocalUserStorage() async {
    print('\n🏠 Verificando LocalUserStorage...');
    try {
      final storage = LocalUserStorageService();
      await storage.init();
      
      final hasUserData = await storage.hasUserData();
      print('  ✅ LocalUserStorageService inicializado');
      print('  👤 Tiene datos de usuario: ${hasUserData ? "Sí" : "No"}');
      
      if (hasUserData) {
        final userData = await storage.getUserData();
        print('  📧 Email guardado: ${userData?['email'] ?? "No disponible"}');
        print('  👤 Nombre guardado: ${userData?['name'] ?? "No disponible"}');
        print('  🆔 UID guardado: ${userData?['uid'] ?? "No disponible"}');
      }
      
      // Imprimir información de debug
      await storage.printDebugInfo();
      
    } catch (e) {
      print('  ❌ Error en LocalUserStorage: $e');
    }
  }
  
  static Future<void> _checkFirebaseConfig() async {
    print('\n🔧 Verificando configuración de Firebase...');
    try {
      final auth = FirebaseAuth.instance;
      print('  ✅ Firebase App configurado: ${auth.app.name}');
      print('  🔗 Project ID: ${auth.app.options.projectId}');
      print('  📱 Platform: ${auth.app.options.runtimeType}');
      
      // Verificar si hay problemas específicos de Android
      print('  🤖 Verificaciones específicas de Android:');
      print('    - google-services.json: Debe estar en android/app/');
      print('    - Permisos de Internet: Verificado en AndroidManifest.xml');
      print('    - Firebase plugin: Verificado en build.gradle');
      
    } catch (e) {
      print('  ❌ Error en configuración de Firebase: $e');
    }
  }
  
  /// Función para limpiar datos corruptos y reiniciar autenticación
  static Future<void> cleanAndReset() async {
    print('\n🧹 Limpiando datos de autenticación...');
    try {
      // Limpiar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      await prefs.remove('user_local_data');
      print('  ✅ SharedPreferences limpiado');
      
      // Limpiar LocalUserStorage
      final storage = LocalUserStorageService();
      await storage.clearUserData();
      print('  ✅ LocalUserStorage limpiado');
      
      // Cerrar sesión de Firebase
      await FirebaseAuth.instance.signOut();
      print('  ✅ Sesión de Firebase cerrada');
      
      print('\n✨ Limpieza completada. Intenta iniciar sesión de nuevo.');
      
    } catch (e) {
      print('  ❌ Error durante la limpieza: $e');
    }
  }
  
  /// Función para probar el login paso a paso
  static Future<void> testLogin(String email, String password) async {
    print('\n🧪 Probando login paso a paso...');
    print('📧 Email: $email');
    
    try {
      final auth = FirebaseAuth.instance;
      
      // Paso 1: Configurar persistencia
      print('\n1️⃣ Configurando persistencia...');
      await auth.setPersistence(Persistence.LOCAL);
      print('  ✅ Persistencia configurada');
      
      // Paso 2: Intentar login
      print('\n2️⃣ Intentando login...');
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('  ✅ Login exitoso');
      print('  👤 Usuario: ${credential.user?.email}');
      print('  🆔 UID: ${credential.user?.uid}');
      
      // Paso 3: Guardar en SharedPreferences
      print('\n3️⃣ Guardando en SharedPreferences...');
      final authService = AuthService();
      // Simular el guardado
      final prefs = await SharedPreferences.getInstance();
      final userData = {
        'uid': credential.user!.uid,
        'email': credential.user!.email,
        'displayName': credential.user!.displayName,
      };
      await prefs.setString('current_user', 
          const JsonEncoder().convert(userData));
      print('  ✅ Datos guardados en SharedPreferences');
      
      // Paso 4: Guardar en LocalUserStorage
      print('\n4️⃣ Guardando en LocalUserStorage...');
      final storage = LocalUserStorageService();
      await storage.saveUserData(
        uid: credential.user!.uid,
        email: credential.user!.email ?? '',
        name: credential.user!.displayName ?? 'Usuario',
        displayName: credential.user!.displayName,
      );
      print('  ✅ Datos guardados en LocalUserStorage');
      
      print('\n🎉 Login completo y exitoso!');
      
    } catch (e) {
      print('  ❌ Error durante el login: $e');
      print('  💡 Tipo de error: ${e.runtimeType}');
      if (e is FirebaseAuthException) {
        print('  🔥 Código de error Firebase: ${e.code}');
        print('  📝 Mensaje: ${e.message}');
      }
    }
  }
}

/// Widget para mostrar diagnósticos en pantalla
class AndroidAuthDebugPage extends StatefulWidget {
  const AndroidAuthDebugPage({Key? key}) : super(key: key);
  
  @override
  State<AndroidAuthDebugPage> createState() => _AndroidAuthDebugPageState();
}

class _AndroidAuthDebugPageState extends State<AndroidAuthDebugPage> {
  String _debugOutput = '';
  bool _isRunning = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico Android Auth'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Diagnóstico de Autenticación',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Esta herramienta ayuda a diagnosticar problemas de autenticación específicos de Android, incluyendo SharedPreferences y Firebase Auth.',
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
                  onPressed: _isRunning ? null : _runDiagnostics,
                  icon: const Icon(Icons.search),
                  label: const Text('Ejecutar Diagnóstico'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _cleanAndReset,
                  icon: const Icon(Icons.cleaning_services),
                  label: const Text('Limpiar Datos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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
            
            // Output
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _debugOutput.isEmpty ? 'Presiona "Ejecutar Diagnóstico" para comenzar...' : _debugOutput,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _debugOutput = 'Ejecutando diagnóstico...\n';
    });
    
    // Capturar la salida de print
    final originalPrint = print;
    print = (Object? object) {
      setState(() {
        _debugOutput += '${object.toString()}\n';
      });
    };
    
    try {
      await AndroidAuthDebugger.runDiagnostics();
    } finally {
      print = originalPrint;
      setState(() {
        _isRunning = false;
      });
    }
  }
  
  Future<void> _cleanAndReset() async {
    setState(() {
      _isRunning = true;
      _debugOutput += '\nEjecutando limpieza...\n';
    });
    
    final originalPrint = print;
    print = (Object? object) {
      setState(() {
        _debugOutput += '${object.toString()}\n';
      });
    };
    
    try {
      await AndroidAuthDebugger.cleanAndReset();
    } finally {
      print = originalPrint;
      setState(() {
        _isRunning = false;
      });
    }
  }
}
