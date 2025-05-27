import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'features/accessibility/infrastructure/dependency_injection.dart';
import 'features/map/infrastructure/di/map_dependencies.dart';
import 'features/map/presentation/pages/map_page.dart';
import 'features/accessibility/presentation/providers/accessibility_provider.dart';
import 'features/accessibility/presentation/widgets/accessibility_wrapper.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_pages.dart';
import 'features/users/presentation/profile_page.dart';
import 'features/map/infrastructure/providers/map_filters_provider.dart';
import 'features/forum/presentation/screens/forum_screen.dart';
import 'features/forum/di/forum_module.dart';
import 'features/notifications/infrastructure/services/firebase_messaging_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/service/auth_service.dart';

// Constantes para URLs de mapas en diferentes estilos
const String kDefaultMapUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const String kHighContrastMapUrl = 'https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png';

final getIt = GetIt.instance;

void setupDependencies() {
  // Registrar dependencias por características
  registerMapDependencies(getIt);
  configureAccessibilityDependencies(); // Registrar servicios de accesibilidad
  getIt.registerSingleton<AuthService>(authService); // Use the global singleton instance directly
  ForumModule.init(); // Registrar dependencias del foro
  
  // Registrar el servicio de notificaciones
  getIt.registerSingleton<FirebaseMessagingService>(FirebaseMessagingService());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await authService.initPrefs(); // Use the public method instead
  setupDependencies();
  
  // Inicializar el servicio de notificaciones
  final messagingService = getIt<FirebaseMessagingService>();
  await messagingService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ... tus providers existentes ...
        
        // Añadir el provider de accesibilidad
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
        
        // Añadir el provider de filtros del mapa
        ChangeNotifierProvider(create: (_) => MapFiltersProvider()),
      ],
      child: Consumer<AccessibilityProvider>(
        builder: (context, accessibilityProvider, _) {
          return MaterialApp(
            title: 'Barrera Cero',
            theme: accessibilityProvider.getTheme(ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E88E5),
                brightness: Brightness.light,
              ),              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )),
            initialRoute: '/',            routes: {
              '/': (context) => AccessibilityWrapper(child: const MapPage()),
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/profile': (context) {
                final args = ModalRoute.of(context)?.settings.arguments as String?;
                if (args == null) {
                  return const LoginPage(); // Redirigir al login si no hay ID de usuario
                }
                return ProfilePage(userId: args);
              },
              '/forum': (context) => const ForumScreen(),
            },
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
