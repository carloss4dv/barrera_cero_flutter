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
  }/// Obtiene todos los desafíos de reportes con progreso actualizado
  Future<List<Challenge>> getChallenges() async {
    print('=== DEBUG: MockChallengeService.getChallenges() - INICIANDO ===');
    
    final challenges = _getBaseChallenges();
    final updatedChallenges = <Challenge>[];

    for (final challenge in challenges) {
      print('=== DEBUG: Actualizando progreso para desafío: ${challenge.title} ===');
      final updatedChallenge = await _reportChallengeService.updateChallengeProgress(challenge);
      print('=== DEBUG: Desafío actualizado - Progreso: ${updatedChallenge.currentProgress}/${updatedChallenge.target} ===');
      updatedChallenges.add(updatedChallenge);
    }

    print('=== DEBUG: MockChallengeService.getChallenges() - COMPLETADO, retornando ${updatedChallenges.length} desafíos ===');
    return updatedChallenges;
  }

  /// Verifica y otorga puntos si algún desafío acaba de ser completado
  Future<List<Challenge>> checkAndAwardCompletedChallenges() async {
    final challenges = _getBaseChallenges();
    final completedChallenges = <Challenge>[];

    for (final challenge in challenges) {
      final wasJustCompleted = await _reportChallengeService.wasJustCompleted(challenge);
      if (wasJustCompleted) {
        await _reportChallengeService.awardChallengePoints(challenge);
        completedChallenges.add(challenge);
      }
    }

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
