import 'package:get_it/get_it.dart';
import '../domain/i_forum_service.dart';
import '../data/forum_service.dart';

class ForumModule {
  static void init() {
    final getIt = GetIt.instance;
    
    getIt.registerLazySingleton<IForumService>(
      () => ForumService(),
    );
  }
} 