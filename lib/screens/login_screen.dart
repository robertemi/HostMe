import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/auth_service.dart';
import 'register_screen.dart';
import 'root_shell.dart';
import 'account_setup_screen.dart';
import 'forgot_password_screen.dart';
import '../services/profile_service.dart';
import '../utils/notifications.dart';
import '../widgets/parallax_tilt.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _authService.signIn(email: email, password: password);
      if (!mounted) return;
      if (response.user != null) {
        // Show a success banner/snack
        await showAppSuccess(context, 'Login successful!');

        // Check whether the user's profile is complete. If it is, navigate to
        // the persistent RootShell so the bottom navigation and PageView are
        // available. If not, send the user to the account setup flow.
        final userId = response.user!.id;
        final complete = await ProfileService().isProfileComplete(userId);
        if (complete) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const RootShell()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AccountSetupScreen()),
          );
        }
      } else {
        _showError('Login failed. Please check credentials.');
      }
    } catch (e) {
      _showError('Login error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      showAppError(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ParallaxTilt(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 8),
                        Text('HostMe', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Welcome Back!', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Text('Log in to find your perfect roommate and place.', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.9))),
                    const SizedBox(height: 24),

                    Text('Email or Username', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email or username',
                        filled: true,
                        fillColor: theme.inputDecorationTheme.fillColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Password', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        filled: true,
                        fillColor: theme.inputDecorationTheme.fillColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.dividerColor)),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                        },
                        child: Text('Forgot Password?', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: theme.colorScheme.primary)),
                      ),
                    ),

                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : Text('Log In', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),

                    const SizedBox(height: 20),
                    Row(children: [const Expanded(child: Divider()), const SizedBox(width: 8), Text('Or log in with', style: GoogleFonts.plusJakartaSans(color: theme.colorScheme.onSurface.withOpacity(0.8))), const SizedBox(width: 8), const Expanded(child: Divider())]),
                    const SizedBox(height: 16),

                    OutlinedButton(
                      onPressed: _isLoading ? null : () async {
                        setState(() => _isLoading = true);
                        try {
                          final response = await _authService.signInWithGoogleNative();
                          if (!mounted) return;
                          if (response.user != null) {
                            await showAppSuccess(context, 'Google sign-in successful!');
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const RootShell()),
                              (route) => false,
                            );
                          } else {
                            _showError('Google sign-in failed. Please try again.');
                          }
                        } catch (e) {
                          if (mounted) _showError('Google sign-in error: ${e.toString()}');
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      style: OutlinedButton.styleFrom(backgroundColor: theme.cardColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: theme.dividerColor)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [SvgPicture.asset('assets/images/google_logo.svg', width: 20, height: 20), const SizedBox(width: 8), Text('Continue with Google', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: theme.colorScheme.onSurface))]),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(backgroundColor: theme.cardColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: theme.dividerColor)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.apple, size: 20), const SizedBox(width: 8), Text('Continue with Apple', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: theme.colorScheme.onSurface))]),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.plusJakartaSans(color: theme.colorScheme.onSurface.withOpacity(0.9)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const RegisterScreen(),
                                transitionsBuilder: (_, animation, __, child) {
                                  final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
                                  final scale = Tween(begin: 0.98, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
                                  return FadeTransition(opacity: fade, child: ScaleTransition(scale: scale, child: child));
                                },
                                transitionDuration: const Duration(milliseconds: 260),
                              ));
                            },
                            child: Text('Sign Up', style: GoogleFonts.plusJakartaSans(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
