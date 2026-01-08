import 'package:flutter/material.dart';
import 'dart:ui';
// foundation imports removed (no platform-gated Firebase initialization)
import 'package:supabase_flutter/supabase_flutter.dart';
// Firebase packages removed — app uses local notifications only
import 'config/supabase_config.dart';
import 'theme.dart';
import 'widgets/liquid_glass_background.dart';
import 'package:host_me/screens/login_screen.dart';
import 'package:host_me/screens/root_shell.dart';
import 'package:host_me/screens/account_setup_screen.dart';
import 'services/profile_service.dart';
import 'services/notification_service.dart';
import 'services/feedback_service.dart';

// No Firebase initialization or background FCM handler — local notifications only

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialize notifications (local only)
  await NotificationService().init();
  // Request local notification permissions (Android 13+, iOS)
  await NotificationService().requestPermissions();
  
  runApp(const MyApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: AppScrollBehavior(),
      title: 'HostMe',
      theme: AppTheme.glassTheme,
      builder: (context, child) => LiquidGlassBackground(child: child),
      home: const InitialRouter(),
    );
  }
}

class InitialRouter extends StatefulWidget {
  const InitialRouter({super.key});

  @override
  State<InitialRouter> createState() => _InitialRouterState();
}

class _InitialRouterState extends State<InitialRouter> {
  Future<Widget> _resolve() async {
    final session = Supabase.instance.client.auth.currentSession;

    // If there's no session, show the login screen.
    if (session == null) return const LoginScreen();

    // If the user is signed in, ensure their profile is complete. If it is,
    // show the RootShell (persistent shell with bottom navigation). Otherwise
    // send them through account setup.
    final userId = session.user.id;
    final complete = await ProfileService().isProfileComplete(userId);
    return complete ? const RootShell() : const AccountSetupScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _resolve(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data ?? const LoginScreen();
      },
    );
  }
}
