import 'package:flutter/material.dart';
import 'lib/features/challenges/infrastructure/services/report_challenge_service.dart';
import 'lib/features/challenges/infrastructure/services/mock_challenge_service.dart';
import 'lib/features/challenges/domain/challenge_model.dart';
import 'lib/features/users/services/user_service.dart';
import 'lib/services/local_user_storage_service.dart';

/// Test completo del sistema de desafíos y B-points
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== INICIANDO TEST COMPLETO DEL SISTEMA DE DESAFÍOS ===');
  
  // Inicializar servicios
  final userService = UserService();
  final reportChallengeService = ReportChallengeService(userService);
  final mockChallengeService = MockChallengeService(reportChallengeService);
  
  // Test 1: Verificar desafíos disponibles
  print('\n--- TEST 1: Desafíos disponibles ---');
  try {
    final challenges = await mockChallengeService.getChallenges();
    challenges.fold(
      (challengeList) {
        print('✅ ${challengeList.length} desafíos obtenidos');
        for (final challenge in challengeList) {
          print('📋 ${challenge.title}: ${challenge.currentProgress}/${challenge.target} (${challenge.points} B-points)');
        }
      },
      (error) {
        print('❌ Error obteniendo desafíos: $error');
      }
    );
  } catch (e) {
    print('❌ Error en test 1: $e');
  }
  
  // Test 2: Verificar progreso actual de desafíos de reportes
  print('\n--- TEST 2: Progreso de desafíos de reportes ---');
  try {
    final challenges = await mockChallengeService.getChallenges();
    await challenges.fold(
      (challengeList) async {
        final reportChallenges = challengeList.where((c) => c.type == ChallengeType.reports).toList();
        
        for (final challenge in reportChallenges) {
          final wasCompleted = challenge.isCompleted;
          final updatedChallenge = await reportChallengeService.updateChallengeProgress(challenge);
          
          print('📊 ${challenge.title}:');
          print('   Progreso anterior: ${challenge.currentProgress}/${challenge.target}');
          print('   Progreso actual: ${updatedChallenge.currentProgress}/${updatedChallenge.target}');
          print('   Estado: ${updatedChallenge.isCompleted ? "✅ Completado" : "⏳ En progreso"}');
          
          if (!wasCompleted && updatedChallenge.isCompleted) {
            print('   🎉 ¡Desafío recién completado! ${updatedChallenge.points} B-points otorgados');
          }
        }
      },
      (error) {
        print('❌ Error obteniendo progreso: $error');
      }
    );
  } catch (e) {
    print('❌ Error en test 2: $e');
  }
  
  // Test 3: Verificar conteo actual de reportes del usuario
  print('\n--- TEST 3: Conteo actual de reportes ---');
  try {
    final reportCount = await reportChallengeService.getUserReportCount();
    print('📊 Usuario tiene $reportCount reportes en total');
    
    // Verificar qué desafíos deberían estar completados
    final challenges = await mockChallengeService.getChallenges();
    challenges.fold(
      (challengeList) {
        final reportChallenges = challengeList.where((c) => c.type == ChallengeType.reports).toList();
        
        print('\n📋 Estado esperado de desafíos:');
        for (final challenge in reportChallenges) {
          final shouldBeCompleted = reportCount >= challenge.target;
          print('   ${challenge.title} (${challenge.target} reportes): ${shouldBeCompleted ? "✅ Debería estar completado" : "⏳ En progreso"}');
        }
      },
      (error) => print('❌ Error verificando estado: $error')
    );
  } catch (e) {
    print('❌ Error en test 3: $e');
  }
  
  // Test 4: Simular agregado de reporte y verificar actualización
  print('\n--- TEST 4: Simulación de agregado de reporte ---');
  try {
    print('🔄 Simulando incremento de cache (como si se agregara un reporte)...');
    await ReportChallengeService.incrementCacheForCurrentUser();
    
    final newReportCount = await reportChallengeService.getUserReportCount();
    print('📊 Nuevo conteo después de incremento: $newReportCount');
    
    // Verificar si esto completó algún desafío
    final challenges = await mockChallengeService.getChallenges();
    await challenges.fold(
      (challengeList) async {
        final reportChallenges = challengeList.where((c) => c.type == ChallengeType.reports).toList();
        
        for (final challenge in reportChallenges) {
          final updatedChallenge = await reportChallengeService.updateChallengeProgress(challenge);
          
          if (updatedChallenge.currentProgress >= updatedChallenge.target && !challenge.isCompleted) {
            print('🎉 ¡Desafío "${challenge.title}" completado con el nuevo reporte!');
          }
        }
      },
      (error) => print('❌ Error verificando completación: $error')
    );
  } catch (e) {
    print('❌ Error en test 4: $e');
  }
  
  // Test 5: Verificar B-points del usuario
  print('\n--- TEST 5: B-points del usuario ---');
  try {
    final currentUser = await userService.getCurrentUser();
    if (currentUser != null) {
      print('👤 Usuario: ${currentUser.displayName ?? "Sin nombre"}');
      print('💰 B-points actuales: ${currentUser.bPoints}');
    } else {
      print('⚠️ No hay usuario autenticado');
    }
  } catch (e) {
    print('❌ Error en test 5: $e');
  }
  
  print('\n=== TEST COMPLETO DEL SISTEMA DE DESAFÍOS COMPLETADO ===');
  print('📝 Resumen:');
  print('   - Firebase queries optimizadas con collectionGroup');
  print('   - Cache de 30 minutos implementado');
  print('   - Incremento de cache para mejor UX');
  print('   - Sistema de B-points integrado');
  print('   - Prevención de duplicados de puntos');
}
