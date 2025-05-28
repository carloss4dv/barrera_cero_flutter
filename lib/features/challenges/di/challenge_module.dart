import 'package:get_it/get_it.dart';
import '../infrastructure/services/mock_challenge_service.dart';
import '../infrastructure/services/report_challenge_service.dart';
import '../../users/services/user_service.dart';

class ChallengeModule {
  static void init() {
    final getIt = GetIt.instance;
    
    // Registrar ReportChallengeService
    getIt.registerFactory<ReportChallengeService>(
      () => ReportChallengeService(
        getIt<UserService>(),
      ),
    );
      // Registrar MockChallengeService
    getIt.registerFactory<MockChallengeService>(
      () => MockChallengeService(
        getIt<ReportChallengeService>(),
      ),
    );
  }
}