import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:surveys/core/constants/colors.dart';
import 'package:surveys/screens/login_screen.dart';
import 'package:surveys/screens/main_screen.dart';
import 'package:surveys/screens/reset_password_screen.dart';
import 'package:surveys/shared/widgets/wordmark.dart';

enum AppRoute { splash, auth, app, recovery }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env
  await dotenv.load(fileName: "assets/.env");

  // Init Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  AppRoute _route = AppRoute.splash;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _resolveInitialSession();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      _onAuthEvent,
    );
  }

  void _resolveInitialSession() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final hasSession = Supabase.instance.client.auth.currentSession != null;
    setState(() {
      _route = hasSession ? AppRoute.app : AppRoute.auth;
    });
  }

  void _onAuthEvent(AuthState state) {
    if (_route == AppRoute.splash) return;
    switch (state.event) {
      case AuthChangeEvent.passwordRecovery:
        setState(() => _route = AppRoute.recovery);
      case AuthChangeEvent.signedOut:
        setState(() => _route = AppRoute.auth);
      case AuthChangeEvent.userUpdated:
        setState(() => _route = AppRoute.app);
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.initialSession:
      case AuthChangeEvent.tokenRefreshed:
        if (_route == AppRoute.recovery) return;
        final hasSession = Supabase.instance.client.auth.currentSession != null;
        setState(() {
          _route = hasSession ? AppRoute.app : AppRoute.auth;
        });
      default:
        break;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'InterTight',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: AppColors.atomictangerine,
          onSecondary: Colors.white,
          surface: AppColors.background,
          onSurface: Colors.black,
          error: AppColors.error,
          onError: Colors.white,
        ),
        textTheme: const TextTheme(
          // Display — hero numbers, huge titles
          displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          // Headline — screen-level headings
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5, height: 1.1),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          // Title — card / question headings
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          // Body — readable text
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 15),
          bodySmall: TextStyle(fontSize: 14),
          // Label — metadata, captions, links
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(fontSize: 12),
          labelSmall: TextStyle(fontSize: 10),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.atomictangerine,
        ),
      ),
      home: switch (_route) {
        AppRoute.splash => const _SplashScreen(),
        AppRoute.auth => const LoginScreen(),
        AppRoute.app => const MainScreen(),
        AppRoute.recovery => const ResetPasswordScreen(),
      },
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: const AppWordmark(fontSize: 52),
        ),
      ),
    );
  }
}
