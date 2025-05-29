import 'package:get_it/get_it.dart';
import '../services/mock_challenge_service.dart';
import '../services/report_challenge_service.dart';
import '../services/distance_challenge_service.dart';
import '../services/distance_tracking_service.dart';
import '../../../users/services/user_service.dart';

class ChallengeModule {
  static void init() {
    final getIt = GetIt.instance;
    
    // Registrar DistanceTrackingService como singleton
    getIt.registerSingleton<DistanceTrackingService>(
      DistanceTrackingService(),
    );
    
    // Registrar ReportChallengeService
    getIt.registerFactory<ReportChallengeService>(
      () => ReportChallengeService(
        getIt<UserService>(),
      ),
    );
    
    // Registrar DistanceChallengeService
    getIt.registerFactory<DistanceChallengeService>(
      () => DistanceChallengeService(
        getIt<UserService>(),
        getIt<DistanceTrackingService>(),
      ),
    );
    
    // Registrar MockChallengeService
    getIt.registerFactory<MockChallengeService>(
      () => MockChallengeService(
        getIt<ReportChallengeService>(),
        getIt<DistanceChallengeService>(),
      ),
    );
  }
}
