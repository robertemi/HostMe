import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'theme.dart';
import 'widgets/liquid_glass_background.dart';
import 'package:host_me/screens/login_screen.dart';
import 'package:host_me/screens/root_shell.dart';


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
      // Builder paints a liquid-glass background behind all routes
      builder: (context, child) => LiquidGlassBackground(child: child),
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const RootShell();
    } else {
      return const LoginScreen();
    }
  }
}