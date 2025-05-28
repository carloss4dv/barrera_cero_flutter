import 'package:barrera_cero/features/accessibility/infrastructure/services/mock_accessibility_report_service.dart';
import 'package:barrera_cero/features/challenges/infrastructure/services/report_challenge_service.dart';
import 'package:barrera_cero/features/users/services/user_service.dart';
import 'package:barrera_cero/services/local_user_storage_service.dart';

void main() async {
  print('=== TEST DEBUG DESAFÍOS ===');
  
  // Crear instancia del servicio de reportes
  final reportService = MockAccessibilityReportService();
  
  // Crear instancia del servicio de usuarios (usando mock)
  final userService = UserService();
  
  // Crear instancia del servicio de desafíos
  final challengeService = ReportChallengeService(userService, reportService);
  
  print('1. Obteniendo todos los reportes...');
  final allReports = await reportService.getAllReports();
  print('Total de reportes: ${allReports.length}');
  
  print('\n2. Listando reportes por usuario:');
  final userReportCounts = <String, int>{};
  for (final report in allReports) {
    userReportCounts[report.userId] = (userReportCounts[report.userId] ?? 0) + 1;
  }
  
  userReportCounts.forEach((userId, count) {
    print('Usuario $userId: $count reportes');
  });
  
  print('\n3. Verificando usuario actual...');
  final localStorage = LocalUserStorageService();
  await localStorage.init();
  final currentUserId = await localStorage.getUserId();
  print('Usuario actual UID: $currentUserId');
  
  print('\n4. Obteniendo conteo de reportes del usuario actual...');
  final reportCount = await challengeService.getUserReportCount();
  print('Reportes del usuario actual: $reportCount');
  
  print('\n=== FIN TEST ===');
}
