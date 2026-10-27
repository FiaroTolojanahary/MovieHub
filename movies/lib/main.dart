
import 'package:colorize_lumberdash/colorize_lumberdash.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:flutter_application_1/ui/theme/theme.dart';

import 'package:flutter_application_1/providers.dart';
import 'package:flutter_application_1/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
// Généré par `flutterfire configure` (non fourni : il contient TON projet Firebase)
import 'firebase_options.dart';

/// This is the main entry point for Flutter
/// Use the runApp method to start your app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  putLumberdashToWork(withClients: [
    ColorizeLumberdash(),
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Crashlytics n'existe que sur Android, iOS et macOS (ni web, ni Windows, ni Linux).
  final crashlyticsSupported = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);
  if (crashlyticsSupported) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
  ));
  if (!isWeb()) {
    await dotenv.load(fileName: '.env');
  }
  if (isDesktop()) {
    await DesktopWindow.setWindowSize(const Size(700, 600));

    await DesktopWindow.setMinWindowSize(const Size(700, 600));
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  // Chapitre 13 (migration) : plus de addPostFrameCallback / createWindowsMenus()
  // ni de variable `initialized`. Sous Windows, la barre de menus Material
  // (MenuBar + CallbackShortcuts) est construite dans MainScreen.

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final menuManager = ref.watch(menuManagerProvider);
    if (isMac()) {
      return PlatformMenuBar(
        menus: menuManager.createMenus(),
        child: MaterialApp.router(
          routerConfig: router.config(),
          title: 'Movies',
          debugShowCheckedModeBanner: false,
          theme: createTheme(),
        ),
      );
    } else {
      return MaterialApp.router(
        routerConfig: router.config(),
        title: 'Movies',
        debugShowCheckedModeBanner: false,
        theme: createTheme(),
      );
    }
  }
}
