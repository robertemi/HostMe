import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'theme.dart';
import 'widgets/liquid_glass_background.dart';
import 'package:host_me/screens/login_screen.dart';
import 'package:host_me/screens/root_shell.dart';
import 'package:host_me/screens/account_setup_screen.dart';
import 'package:host_me/screens/reset_password_screen.dart';
import 'services/profile_service.dart';
import 'package:url_strategy/url_strategy.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HostMe',
      theme: AppTheme.glassTheme,
      builder: (context, child) => LiquidGlassBackground(child: child),
      initialRoute: '/',
      routes: {
        '/': (context) => const InitialRouter(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
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
  debugPrint("ROUTER: Uri.base = ${Uri.base}");
  debugPrint("ROUTER: path = ${Uri.base.path}");
  debugPrint("ROUTER: fragment = ${Uri.base.fragment}");
  final session = Supabase.instance.client.auth.currentSession;

  // If the URL contains the reset-password route, show that screen so
  // the reset flow can attempt to restore the recovery session and let
  // the user enter a new password.
  final uri = Uri.base;
  final hasResetPath =
      uri.path.contains('/reset-password') || uri.fragment.contains('reset-password');

  if (session == null) {
    if (hasResetPath) {
      return const ResetPasswordScreen();
    }
    return const LoginScreen();
  }

  // If the user is signed in, ensure their profile is complete.
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