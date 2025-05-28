import 'package:flutter/material.dart';
import '../../domain/challenge_model.dart';
import 'report_challenge_service.dart';

class MockChallengeService {
  final ReportChallengeService _reportChallengeService;
  
  // Callback para notificar completación de desafíos a la UI
  Function(Challenge challenge, int pointsAwarded)? onChallengeCompleted;

  MockChallengeService(this._reportChallengeService) {
    // Configurar el callback del servicio de reportes
    _reportChallengeService.onChallengeCompleted = (challenge, points) {
      onChallengeCompleted?.call(challenge, points);
    };
  }  /// Obtiene todos los desafíos de reportes con progreso actualizado
  /// Si [justCreatedReport] es true, indica que se acaba de crear un nuevo reporte
  Future<List<Challenge>> getChallenges({bool justCreatedReport = false}) async {
    print('=== DEBUG: MockChallengeService.getChallenges() - INICIANDO, justCreatedReport: $justCreatedReport ===');
    
    final challenges = _getBaseChallenges();
    final updatedChallenges = <Challenge>[];

    for (final challenge in challenges) {
      print('=== DEBUG: Actualizando progreso para desafío: ${challenge.title} ===');
      final updatedChallenge = await _reportChallengeService.updateChallengeProgress(challenge, justCreatedReport: justCreatedReport);
      print('=== DEBUG: Desafío actualizado - Progreso: ${updatedChallenge.currentProgress}/${updatedChallenge.target} ===');
      updatedChallenges.add(updatedChallenge);
    }

    print('=== DEBUG: MockChallengeService.getChallenges() - COMPLETADO, retornando ${updatedChallenges.length} desafíos ===');
    return updatedChallenges;
  }
  /// Verifica y otorga puntos si algún desafío acaba de ser completado
  /// Si [justCreatedReport] es true, indica que se acaba de crear un nuevo reporte
  Future<List<Challenge>> checkAndAwardCompletedChallenges({bool justCreatedReport = false}) async {
    print('=== DEBUG: MockChallengeService.checkAndAwardCompletedChallenges() - justCreatedReport: $justCreatedReport ===');
    
    final challenges = _getBaseChallenges();
    final completedChallenges = <Challenge>[];

    for (final challenge in challenges) {
      final updatedChallenge = await _reportChallengeService.updateChallengeProgress(challenge, justCreatedReport: justCreatedReport);
      
      // Verificar si se completó con este nuevo reporte
      if (updatedChallenge.isCompleted && justCreatedReport) {
        completedChallenges.add(updatedChallenge);
      }
    }

    print('=== DEBUG: MockChallengeService.checkAndAwardCompletedChallenges() - ${completedChallenges.length} desafíos completados ===');
    return completedChallenges;
  }

  List<Challenge> _getBaseChallenges() {
    return [
      Challenge(
        id: '1',
        title: 'Reportador aprendiz',
        description: 'Reporta la accesibilidad de 5 ubicaciones',
        icon: Icons.report,
        points: 100,
        type: ChallengeType.reports,
        target: 5,
        isCompleted: false,
      ),
      Challenge(
        id: '2',
        title: 'Reportador experto',
        description: 'Reporta la accesibilidad de 20 ubicaciones',
        icon: Icons.report_problem,
        points: 300,
        type: ChallengeType.reports,
        target: 20,
        isCompleted: false,
      ),
      Challenge(
        id: '3',
        title: 'Reportador veterano',
        description: 'Reporta la accesibilidad de 50 ubicaciones',
        icon: Icons.verified,
        points: 500,
        type: ChallengeType.reports,
        target: 50,
        isCompleted: false,
      ),
      Challenge(
        id: '4',
        title: 'Reportador maestro',
        description: 'Reporta la accesibilidad de 100 ubicaciones',
        icon: Icons.workspace_premium,
        points: 1000,
        type: ChallengeType.reports,
        target: 100,
        isCompleted: false,
      ),
    ];
  }
}
