import 'package:get_it/get_it.dart';
import '../../domain/i_accessibility_report_service.dart';
import '../services/mock_accessibility_report_service.dart';

/// Registra todos los servicios y repositorios de accesibilidad
void registerAccessibilityProviders() {
  final GetIt getIt = GetIt.instance;
  // Registrar el servicio de reportes de accesibilidad como singleton
  getIt.registerLazySingleton<IAccessibilityReportService>(
    () => MockAccessibilityReportService(),
  );
} 