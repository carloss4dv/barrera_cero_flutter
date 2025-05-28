import 'package:get_it/get_it.dart';
import '../services/mock_challenge_service.dart';
import '../../../users/services/user_service.dart';
import '../../../accessibility/domain/i_accessibility_report_service.dart';

class ChallengeModule {
  static void init() {
    final getIt = GetIt.instance;
    
    // Registrar el servicio de desafíos como factory para obtener nuevas instancias
    getIt.registerFactory<MockChallengeService>(
      () => MockChallengeService(
        getIt<UserService>(),
        getIt<IAccessibilityReportService>(),
      ),
    );
  }
}
