import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barrera_cero/features/accessibility/domain/i_accessibility_report_service.dart';
import 'package:barrera_cero/features/accessibility/domain/i_community_validation_service.dart';
import 'package:barrera_cero/features/accessibility/infrastructure/services/firebase_accessibility_report_service.dart';
import 'package:barrera_cero/features/accessibility/infrastructure/services/community_validation_service.dart';
import 'package:barrera_cero/features/users/services/user_service.dart';

void configureAccessibilityDependencies() {
  final getIt = GetIt.instance;

  // Registrar UserService si no está ya registrado
  if (!getIt.isRegistered<UserService>()) {
    getIt.registerLazySingleton<UserService>(() => UserService());
  }  // Servicios
  getIt.registerLazySingleton<IAccessibilityReportService>(
    () => FirebaseAccessibilityReportService(
      firestore: FirebaseFirestore.instance,
    ),
  );

  getIt.registerLazySingleton<ICommunityValidationService>(
    () => CommunityValidationService(
      FirebaseFirestore.instance,
      getIt<UserService>(),
    ),
  );
}