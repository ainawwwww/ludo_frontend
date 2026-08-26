import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_vibe/core/constants/app_constants.dart';
import 'package:ludo_vibe/core/router/app_router.dart';
import 'package:ludo_vibe/core/services/sound_service.dart';
import 'package:ludo_vibe/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: LudoVibeApp(),
    ),
  );
}

class LudoVibeApp extends ConsumerStatefulWidget {
  const LudoVibeApp({super.key});

  @override
  ConsumerState<LudoVibeApp> createState() => _LudoVibeAppState();
}

class _LudoVibeAppState extends ConsumerState<LudoVibeApp> {
  @override
  void initState() {
    super.initState();
    // Auto-start background music (SoundMain.mp3) on app launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundService().startBgMusic();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return Listener(
      onPointerDown: (_) {
        // Resume/Start music if blocked initially by web browser autoplay restrictions
        final sound = SoundService();
        if (sound.isMusicEnabled && !sound.isBgPlaying) {
          sound.startBgMusic();
        }
      },
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: router,
      ),
    );
  }
}
