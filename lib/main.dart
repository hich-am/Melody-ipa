import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'screens/auth/gateway_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'navigation/main_scaffold.dart';
import 'core/services/audio_player_service.dart';
import 'core/providers/music_provider.dart';
import 'core/providers/theme_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NOTE: After running `flutterfire configure`, uncomment the import below
// and pass `options: DefaultFirebaseOptions.currentPlatform` to initializeApp.
// ─────────────────────────────────────────────────────────────────────────────
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Background audio init (MUST come before Firebase) ──────────────────
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.melody.app.melody.channel.audio',
    androidNotificationChannelName: 'Melody Audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );

  // ── Firebase init ──────────────────────────────────────────────────────────
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase init failed: $e');
  }

  // ── Singleton audio player init ──────────────────────────────────────────
  try {
    await AudioPlayerService.instance.init();
  } catch (e) {
    debugPrint('⚠️ AudioPlayerService init failed: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
      ],
      child: const MelodyApp(),
    ),
  );
}

class MelodyApp extends StatelessWidget {
  const MelodyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Melody - Secure Gateway',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.currentTheme,
          initialRoute: '/gateway',
      routes: {
        '/gateway': (context) => const GatewayScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const MainScaffold(),
      },
        );
      },
    );
  }
}
