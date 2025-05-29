import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/services/local_user_storage_service.dart';
import 'lib/services/logout_cleanup_service.dart';
import 'lib/features/challenges/domain/challenge_model.dart';

/// Script de prueba para verificar el sistema de notificaciones únicas
/// Este script simula el proceso de:
/// 1. Usuario completa un desafío por primera vez -> Muestra notificación
/// 2. Usuario vuelve a ver el mismo desafío -> NO muestra notificación 
/// 3. Usuario hace logout -> Limpia notificaciones
/// 4. Usuario hace login de nuevo -> Puede volver a ver notificaciones

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 === INICIANDO PRUEBAS DEL SISTEMA DE NOTIFICACIONES ÚNICAS ===\n');
  
  await testNotificationSystem();
  
  print('\n✅ === PRUEBAS COMPLETADAS ===');
}

Future<void> testNotificationSystem() async {
  // Simular un usuario
  const String testUserId = 'user_test_12345';
  const String testChallengeId = 'challenge_walk_1km';
  
  print('👤 Usuario de prueba: $testUserId');
  print('🎯 Desafío de prueba: $testChallengeId\n');
  
  // Limpiar datos previos para empezar desde cero
  await _clearTestData(testUserId);
  
  // TEST 1: Primera vez - debe mostrar notificación
  print('📋 TEST 1: Primera verificación (debería permitir mostrar)');
  bool shouldShow1 = await _simulateNotificationCheck(testChallengeId, testUserId);
  print('   Resultado: ${shouldShow1 ? "✅ PERMITIR mostrar" : "❌ NO mostrar"}');
  
  if (shouldShow1) {
    await _simulateMarkAsShown(testChallengeId, testUserId);
    print('   ✅ Notificación marcada como mostrada\n');
  }
  
  // TEST 2: Segunda vez - NO debe mostrar notificación
  print('📋 TEST 2: Segunda verificación (NO debería mostrar)');
  bool shouldShow2 = await _simulateNotificationCheck(testChallengeId, testUserId);
  print('   Resultado: ${shouldShow2 ? "❌ PERMITIR mostrar (ERROR!)" : "✅ NO mostrar (CORRECTO)"}');
  
  // TEST 3: Simular logout y limpieza
  print('\n📋 TEST 3: Simulando logout y limpieza...');
  await LogoutCleanupService.performCompleteCleanup(userId: testUserId);
  print('   ✅ Limpieza de logout completada');
  
  // TEST 4: Después del logout - debe mostrar notificación de nuevo
  print('\n📋 TEST 4: Después del logout (debería permitir mostrar de nuevo)');
  bool shouldShow4 = await _simulateNotificationCheck(testChallengeId, testUserId);
  print('   Resultado: ${shouldShow4 ? "✅ PERMITIR mostrar" : "❌ NO mostrar"}');
  
  // Limpiar datos de prueba
  await _clearTestData(testUserId);
  print('\n🧹 Datos de prueba limpiados');
}

/// Simula la verificación de si una notificación ya fue mostrada
Future<bool> _simulateNotificationCheck(String challengeId, String userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notification_shown_${challengeId}_$userId';
    final alreadyShown = prefs.getBool(key) ?? false;
    
    print('   🔍 Verificando clave: $key');
    print('   📊 Ya mostrada: $alreadyShown');
    
    return !alreadyShown; // Retorna true si NO ha sido mostrada (debe mostrar)
  } catch (e) {
    print('   ❌ Error en verificación: $e');
    return false;
  }
}

/// Simula marcar una notificación como mostrada
Future<void> _simulateMarkAsShown(String challengeId, String userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notification_shown_${challengeId}_$userId';
    await prefs.setBool(key, true);
    print('   💾 Guardado en clave: $key = true');
  } catch (e) {
    print('   ❌ Error marcando como mostrada: $e');
  }
}

/// Limpia datos de prueba
Future<void> _clearTestData(String userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList();
    
    for (final key in keys) {
      if (key.contains('notification_shown_') && key.contains(userId)) {
        await prefs.remove(key);
      }
    }
    
    print('🧹 Datos de prueba limpiados para usuario: $userId');
  } catch (e) {
    print('❌ Error limpiando datos de prueba: $e');
  }
}
