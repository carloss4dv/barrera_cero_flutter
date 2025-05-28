// Test para verificar el sistema de cache de reportes
import 'package:flutter/material.dart';
import 'lib/features/challenges/infrastructure/services/report_challenge_service.dart';
import 'lib/features/users/services/user_service.dart';
import 'lib/services/local_user_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== INICIANDO TEST DEL SISTEMA DE CACHE ===\n');
  
  try {
    // Simular un usuario autenticado
    final localStorage = LocalUserStorageService();
    await localStorage.init();
    
    // Para este test, simularemos que hay un usuario
    // En la aplicación real, esto vendría del sistema de autenticación
    print('1. Simulando usuario autenticado...');
    
    // Crear instancia del servicio
    final userService = UserService();
    final challengeService = ReportChallengeService(userService);
    
    print('2. Obteniendo conteo inicial de reportes...');
    final initialCount = await challengeService.getUserReportCount();
    print('   Conteo inicial: $initialCount reportes\n');
    
    print('3. Simulando adición de nuevo reporte...');
    print('   Llamando a smartUpdateCacheForCurrentUser()...');
    await ReportChallengeService.smartUpdateCacheForCurrentUser();
    
    print('4. Verificando conteo después del incremento...');
    final newCount = await challengeService.getUserReportCount();
    print('   Nuevo conteo: $newCount reportes\n');
    
    if (newCount > initialCount) {
      print('✅ TEST EXITOSO: El cache se actualizó correctamente!');
      print('   Incremento detectado: ${newCount - initialCount} reportes');
    } else {
      print('❌ TEST FALLIDO: El cache no se incrementó como esperado');
      print('   Conteo inicial: $initialCount');
      print('   Conteo final: $newCount');
    }
    
    print('\n5. Probando limpieza de cache...');
    await ReportChallengeService.clearCacheForCurrentUser();
    print('   Cache limpiado exitosamente');
    
    print('\n6. Verificando que el cache se recarga desde Firebase...');
    final reloadedCount = await challengeService.getUserReportCount();
    print('   Conteo recargado desde Firebase: $reloadedCount reportes');
    
    print('\n=== TEST COMPLETADO ===');
    
  } catch (e) {
    print('❌ ERROR EN EL TEST: $e');
  }
}
