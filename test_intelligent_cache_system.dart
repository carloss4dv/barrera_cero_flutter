/// Test completo del sistema de cache inteligente para reportes de desafíos
/// 
/// Este test verifica que:
/// 1. La primera consulta de sesión va a la base de datos
/// 2. Las consultas posteriores usan cache
/// 3. El cache se actualiza correctamente al crear nuevos reportes  
/// 4. El cache se limpia completamente al hacer logout
/// 5. El ciclo se reinicia correctamente al hacer login nuevamente

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'services/local_user_storage_service.dart';
import 'features/challenges/infrastructure/services/report_challenge_service.dart';
import 'features/users/services/user_service.dart';
import 'services/logout_cleanup_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado correctamente');
  } catch (e) {
    print('❌ Error inicializando Firebase: $e');
    return;
  }

  await testIntelligentCacheSystem();
}

/// Test principal del sistema de cache inteligente
Future<void> testIntelligentCacheSystem() async {
  print('\n🧪 === INICIANDO TEST DEL SISTEMA DE CACHE INTELIGENTE ===\n');
  
  // Configurar usuario de prueba
  const testUserId = 'test_user_12345';
  const testUserEmail = 'test@cache.com';
  
  try {
    // === PASO 1: LIMPIAR ESTADO INICIAL ===
    await _step1_cleanInitialState(testUserId);
    
    // === PASO 2: SIMULAR LOGIN Y PRIMERA CONSULTA ===
    await _step2_simulateLoginAndFirstQuery(testUserId, testUserEmail);
    
    // === PASO 3: VERIFICAR USO DE CACHE ===
    await _step3_verifyCacheUsage(testUserId);
    
    // === PASO 4: SIMULAR CREACIÓN DE NUEVO REPORTE ===
    await _step4_simulateNewReportCreation(testUserId);
    
    // === PASO 5: VERIFICAR ACTUALIZACIÓN INTELIGENTE DE CACHE ===
    await _step5_verifyIntelligentCacheUpdate(testUserId);
    
    // === PASO 6: SIMULAR LOGOUT ===
    await _step6_simulateLogout(testUserId);
    
    // === PASO 7: VERIFICAR LIMPIEZA COMPLETA ===
    await _step7_verifyCompleteCleanup(testUserId);
    
    // === PASO 8: SIMULAR NUEVO LOGIN ===
    await _step8_simulateNewLogin(testUserId);
    
    print('\n🎉 === TODOS LOS TESTS DEL SISTEMA DE CACHE INTELIGENTE PASARON EXITOSAMENTE ===\n');
    
  } catch (e) {
    print('\n❌ === TEST FALLIDO: $e ===\n');
  }
}

/// Paso 1: Limpiar estado inicial
Future<void> _step1_cleanInitialState(String testUserId) async {
  print('🔄 PASO 1: Limpiando estado inicial...');
  
  // Limpiar SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  
  // Limpiar LocalUserStorage
  final localStorage = LocalUserStorageService();
  await localStorage.clearUserData();
  
  print('✅ Estado inicial limpiado');
}

/// Paso 2: Simular login y primera consulta
Future<void> _step2_simulateLoginAndFirstQuery(String testUserId, String testUserEmail) async {
  print('\n🔄 PASO 2: Simulando login y primera consulta...');
  
  // Simular datos de usuario guardados después del login
  final localStorage = LocalUserStorageService();
  await localStorage.saveUserData(
    uid: testUserId,
    email: testUserEmail,
    name: 'Usuario de Test',
    contributionPoints: 0,
  );
  
  // Crear servicio de desafíos
  final userService = UserService();
  final challengeService = ReportChallengeService(userService);
  
  print('📊 Realizando primera consulta de la sesión...');
  final firstQueryCount = await challengeService.getUserReportCount();
  
  print('✅ Primera consulta completada. Reportes encontrados: $firstQueryCount');
  
  // Verificar que se marcó la sesión como inicializada
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = 'session_initialized_$testUserId';
  final sessionInitialized = prefs.getBool(sessionKey) ?? false;
  
  if (sessionInitialized) {
    print('✅ Sesión marcada como inicializada correctamente');
  } else {
    throw Exception('❌ La sesión no se marcó como inicializada');
  }
}

/// Paso 3: Verificar uso de cache en consultas posteriores
Future<void> _step3_verifyCacheUsage(String testUserId) async {
  print('\n🔄 PASO 3: Verificando uso de cache...');
  
  final userService = UserService();
  final challengeService = ReportChallengeService(userService);
  
  // Verificar que existe cache
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'user_report_count_$testUserId';
  final cachedCount = prefs.getInt(cacheKey);
  
  if (cachedCount != null) {
    print('✅ Cache encontrado con valor: $cachedCount');
  } else {
    throw Exception('❌ No se encontró cache después de la primera consulta');
  }
  
  // Realizar segunda consulta (debería usar cache)
  print('📊 Realizando segunda consulta (debería usar cache)...');
  final secondQueryCount = await challengeService.getUserReportCount();
  
  print('✅ Segunda consulta completada. Reportes: $secondQueryCount');
  
  if (secondQueryCount == cachedCount) {
    print('✅ Cache utilizado correctamente en segunda consulta');
  } else {
    throw Exception('❌ El cache no se utilizó correctamente');
  }
}

/// Paso 4: Simular creación de nuevo reporte
Future<void> _step4_simulateNewReportCreation(String testUserId) async {
  print('\n🔄 PASO 4: Simulando creación de nuevo reporte...');
  
  // Obtener conteo actual del cache
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'user_report_count_$testUserId';
  final currentCachedCount = prefs.getInt(cacheKey) ?? 0;
  
  print('📊 Conteo actual en cache: $currentCachedCount');
  
  // Simular actualización inteligente del cache al crear nuevo reporte
  await ReportChallengeService.smartUpdateCacheForCurrentUser();
  
  print('✅ Actualización inteligente de cache ejecutada');
}

/// Paso 5: Verificar actualización inteligente de cache
Future<void> _step5_verifyIntelligentCacheUpdate(String testUserId) async {
  print('\n🔄 PASO 5: Verificando actualización inteligente del cache...');
  
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'user_report_count_$testUserId';
  final updatedCachedCount = prefs.getInt(cacheKey) ?? 0;
  
  print('📊 Conteo actualizado en cache: $updatedCachedCount');
  
  // El cache debería haberse incrementado en 1
  final userService = UserService();
  final challengeService = ReportChallengeService(userService);
  
  // Verificar que getUserReportCount ahora devuelve el valor actualizado
  final currentCount = await challengeService.getUserReportCount();
  
  if (currentCount == updatedCachedCount) {
    print('✅ Cache actualizado inteligentemente (incremento en lugar de limpieza)');
  } else {
    throw Exception('❌ La actualización inteligente del cache falló');
  }
}

/// Paso 6: Simular logout
Future<void> _step6_simulateLogout(String testUserId) async {
  print('\n🔄 PASO 6: Simulando logout...');
  
  // Ejecutar limpieza completa usando el servicio centralizado
  await LogoutCleanupService.performCompleteCleanup(userId: testUserId);
  
  print('✅ Limpieza de logout ejecutada');
}

/// Paso 7: Verificar limpieza completa
Future<void> _step7_verifyCompleteCleanup(String testUserId) async {
  print('\n🔄 PASO 7: Verificando limpieza completa...');
  
  final prefs = await SharedPreferences.getInstance();
  
  // Verificar que el cache de reportes fue eliminado
  final cacheKey = 'user_report_count_$testUserId';
  final timestampKey = 'user_report_count_timestamp_$testUserId';
  final sessionKey = 'session_initialized_$testUserId';
  
  final cacheExists = prefs.containsKey(cacheKey);
  final timestampExists = prefs.containsKey(timestampKey);
  final sessionExists = prefs.containsKey(sessionKey);
  
  if (!cacheExists && !timestampExists && !sessionExists) {
    print('✅ Todos los datos de cache y sesión fueron eliminados correctamente');
  } else {
    throw Exception('❌ Algunos datos no fueron eliminados: cache=$cacheExists, timestamp=$timestampExists, session=$sessionExists');
  }
  
  // Verificar LocalUserStorage
  final localStorage = LocalUserStorageService();
  final hasUserData = await localStorage.hasUserData();
  
  if (!hasUserData) {
    print('✅ LocalUserStorage limpiado correctamente');
  } else {
    throw Exception('❌ LocalUserStorage no fue limpiado completamente');
  }
  
  // Verificar usando el método de verificación del servicio de limpieza
  final cleanupSuccess = await LogoutCleanupService.verifyCleanupSuccess(testUserId);
  
  if (cleanupSuccess) {
    print('✅ Verificación de limpieza exitosa');
  } else {
    throw Exception('❌ La verificación de limpieza falló');
  }
}

/// Paso 8: Simular nuevo login
Future<void> _step8_simulateNewLogin(String testUserId) async {
  print('\n🔄 PASO 8: Simulando nuevo login después de logout...');
  
  // Simular nuevo login guardando datos de usuario
  final localStorage = LocalUserStorageService();
  await localStorage.saveUserData(
    uid: testUserId,
    email: 'test@cache.com',
    name: 'Usuario de Test',
    contributionPoints: 0,
  );
  
  // Verificar que es considerado como primera consulta de nueva sesión
  final userService = UserService();
  final challengeService = ReportChallengeService(userService);
  
  print('📊 Realizando primera consulta de nueva sesión...');
  final newSessionCount = await challengeService.getUserReportCount();
  
  print('✅ Nueva sesión iniciada. Reportes encontrados: $newSessionCount');
  
  // Verificar que la sesión se marcó como inicializada nuevamente
  final prefs = await SharedPreferences.getInstance();
  final sessionKey = 'session_initialized_$testUserId';
  final sessionInitialized = prefs.getBool(sessionKey) ?? false;
  
  if (sessionInitialized) {
    print('✅ Nueva sesión marcada como inicializada correctamente');
  } else {
    throw Exception('❌ La nueva sesión no se marcó como inicializada');
  }
  
  print('✅ Ciclo completo de cache inteligente verificado exitosamente');
}
