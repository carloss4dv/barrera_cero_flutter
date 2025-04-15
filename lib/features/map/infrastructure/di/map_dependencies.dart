import 'package:get_it/get_it.dart';
import '../services/firestore_marker_service.dart';
import '../services/marker_service.dart';
import '../services/combined_marker_service.dart';
import '../services/route_service.dart';
import '../../domain/i_marker_service.dart';

/// Registra las dependencias relacionadas con mapas y marcadores
void registerMapDependencies(GetIt getIt) {
  // Registrar servicios
  getIt.registerLazySingleton<IMarkerService>(() => CombinedMarkerService());

  // Registrar RouteService
  getIt.registerLazySingleton<RouteService>(() => RouteService());
} 