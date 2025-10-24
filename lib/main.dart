import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HostMe',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
