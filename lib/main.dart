import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:host_me/screens/home_screen.dart';
import 'package:host_me/screens/account_setup_screen.dart';
import 'package:host_me/screens/login_screen.dart';
import 'services/profile_service.dart';
import 'config/supabase_config.dart';
import 'theme.dart';


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
      theme: AppTheme.lightTheme,
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
    if (session == null) return const LoginScreen();
    final userId = session.user.id;
    final complete = await ProfileService().isProfileComplete(userId);
    return complete ? const HomeScreen() : const AccountSetupScreen();
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