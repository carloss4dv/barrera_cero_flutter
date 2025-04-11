import 'package:get_it/get_it.dart';
import '../../application/marker_cubit.dart';
import '../../domain/i_marker_service.dart';
import '../services/combined_marker_service.dart';

/// Registra las dependencias relacionadas con mapas y marcadores
void registerMapDependencies(GetIt getIt) {
  // Servicios
  getIt.registerLazySingleton<IMarkerService>(() => CombinedMarkerService());
  
  // Cubits
  getIt.registerFactory<MarkerCubit>(() => MarkerCubit());
} 