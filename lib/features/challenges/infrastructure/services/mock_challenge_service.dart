import 'package:flutter/material.dart';
import '../../domain/challenge_model.dart';

class MockChallengeService {
  List<Challenge> getMockChallenges() {
    return [
      Challenge(
        id: '1',
        title: 'Caminante experto',
        description: '¡Has ganado 500 B-Ceros!',
        icon: Icons.directions_walk,
        points: 500,
        isCompleted: true,
      ),
      Challenge(
        id: '2',
        title: 'Reportador aprendiz',
        description: 'Reporta la accesibilidad de 5 ubicaciones',
        icon: Icons.report,
        points: 100,
        isCompleted: false,
      ),
      Challenge(
        id: '3',
        title: 'Caminante aprendiz',
        description: 'Anda 1 kilómetro',
        icon: Icons.directions_walk,
        points: 50,
        isCompleted: false,
      ),
      Challenge(
        id: '4',
        title: 'Explorador urbano',
        description: 'Visita 10 lugares accesibles',
        icon: Icons.explore,
        points: 200,
        isCompleted: false,
      ),
      Challenge(
        id: '5',
        title: 'Reportador experto',
        description: 'Reporta la accesibilidad de 20 ubicaciones',
        icon: Icons.report_problem,
        points: 300,
        isCompleted: false,
      ),
    ];
  }
}
