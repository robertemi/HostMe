import 'package:flutter/material.dart';
import 'package:host_me/screens/houses_screen.dart';
import 'package:host_me/screens/roommate_finder_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      home: const RoommateFinderScreen(),
    );
  }
}