import 'package:get_it/get_it.dart';
import 'package:barrera_cero/features/accessibility/domain/i_accessibility_report_service.dart';
import 'package:barrera_cero/features/accessibility/domain/i_community_validation_service.dart';
import 'package:barrera_cero/features/accessibility/infrastructure/services/mock_accessibility_report_service.dart';
import 'package:barrera_cero/features/accessibility/infrastructure/services/mock_community_validation_service.dart';

void configureAccessibilityDependencies() {
  final getIt = GetIt.instance;

  // Servicios
  getIt.registerLazySingleton<IAccessibilityReportService>(
    () => MockAccessibilityReportService(),
  );

  getIt.registerLazySingleton<ICommunityValidationService>(
    () => MockCommunityValidationService(),
  );
} 