import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/game_provider.dart';
import 'screens/home_screen.dart';
import 'services/audio_manager.dart';
import 'theme/app_theme.dart';
import 'theme/theme_preview_bar.dart';
import 'widgets/guided_tour_overlay.dart';
import 'services/tutorial_route_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioManager().initSettings();
  final game = GameProvider();
  await game.init().timeout(const Duration(seconds: 8), onTimeout: () {});
  runApp(
    ChangeNotifierProvider<GameProvider>.value(
      value: game,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audio = AudioManager();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      Provider.of<GameProvider>(context, listen: false).saveDataNow();
      audio.pauseForBackground();
    } else if (state == AppLifecycleState.resumed) {
      audio.resumeFromBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String themeId = context.select<GameProvider, String>(
      (g) => g.currentTheme.id,
    );
    final ArrowTheme t = AppTheme.byId(themeId);
    AppTheme.active = t;

    // Lets the tutorial recover if the player presses the system back button.
    TutorialRouteObserver.instance.game = context.read<GameProvider>();

    return MaterialApp(
      title: 'Arrowrift',
      debugShowCheckedModeBanner: false,
      navigatorKey: context.read<GameProvider>().navigatorKey, // <--- NEW
      navigatorObservers: [TutorialRouteObserver.instance],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: t.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: t.brand,
          brightness: t.isDark ? Brightness.dark : Brightness.light,
          surface: t.isClassic ? null : t.card,
        ),
        fontFamily: 'Poppins',
      ),
      builder: (context, child) => GuidedTourOverlay(
        child: ThemePreviewShell(child: child ?? const SizedBox.shrink()),
      ),
      home: const HomeScreen(),
    );
  }
}
