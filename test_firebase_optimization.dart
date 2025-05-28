import 'package:flutter/material.dart';
import 'lib/features/challenges/infrastructure/services/report_challenge_service.dart';
import 'lib/features/users/services/user_service.dart';
import 'lib/services/local_user_storage_service.dart';

/// Test script para verificar la optimización de Firebase
/// Este script prueba las consultas optimizadas de reportes
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== INICIANDO TEST DE OPTIMIZACIÓN FIREBASE ===');
  
  // Inicializar servicios
  final userService = UserService();
  final reportChallengeService = ReportChallengeService(userService);
  
  // Test 1: Verificar conteo de reportes con cache
  print('\n--- TEST 1: Conteo de reportes con cache ---');
  try {
    final startTime = DateTime.now();
    final reportCount = await reportChallengeService.getUserReportCount();
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    
    print('✅ Conteo de reportes obtenido: $reportCount');
    print('⏱️ Tiempo de consulta: ${duration.inMilliseconds}ms');
    
    if (duration.inMilliseconds < 5000) {
      print('✅ Performance aceptable (< 5 segundos)');
    } else {
      print('⚠️ Performance mejorable (≥ 5 segundos)');
    }
  } catch (e) {
    print('❌ Error en test 1: $e');
  }
  
  // Test 2: Verificar cache después de primera consulta
  print('\n--- TEST 2: Verificación de cache ---');
  try {
    final startTime = DateTime.now();
    final reportCount2 = await reportChallengeService.getUserReportCount();
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    
    print('✅ Conteo de reportes (segunda consulta): $reportCount2');
    print('⏱️ Tiempo de consulta desde cache: ${duration.inMilliseconds}ms');
    
    if (duration.inMilliseconds < 100) {
      print('✅ Cache funcionando correctamente (< 100ms)');
    } else {
      print('⚠️ Cache no optimizado');
    }
  } catch (e) {
    print('❌ Error en test 2: $e');
  }
  
  // Test 3: Verificar limpieza de cache
  print('\n--- TEST 3: Limpieza de cache ---');
  try {
    await ReportChallengeService.clearCacheForCurrentUser();
    print('✅ Cache limpiado exitosamente');
    
    final startTime = DateTime.now();
    final reportCount3 = await reportChallengeService.getUserReportCount();
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    
    print('✅ Conteo después de limpiar cache: $reportCount3');
    print('⏱️ Tiempo sin cache: ${duration.inMilliseconds}ms');
  } catch (e) {
    print('❌ Error en test 3: $e');
  }
  
  // Test 4: Verificar incremento de cache
  print('\n--- TEST 4: Incremento de cache ---');
  try {
    // Primero obtener un conteo base
    final baseCount = await reportChallengeService.getUserReportCount();
    print('📊 Conteo base: $baseCount');
    
    // Incrementar cache
    await ReportChallengeService.incrementCacheForCurrentUser();
    print('✅ Cache incrementado');
    
    // Verificar que el cache incrementado se devuelve
    final incrementedCount = await reportChallengeService.getUserReportCount();
    print('📊 Conteo después de incrementar: $incrementedCount');
    
    if (incrementedCount == baseCount + 1) {
      print('✅ Incremento de cache funciona correctamente');
    } else {
      print('⚠️ Incremento de cache no refleja el cambio esperado');
    }
  } catch (e) {
    print('❌ Error en test 4: $e');
  }
  
  print('\n=== TEST DE OPTIMIZACIÓN FIREBASE COMPLETADO ===');
}
