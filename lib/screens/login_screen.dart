import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../theme.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'account_setup_screen.dart';
import '../services/profile_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  StreamSubscription<Uri>? _sub;
  Timer? _pollTimer;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen for auth changes and navigate to Home when user signs in.
    _authService.authStateChanges.listen((event) {
      final user = _authService.currentUser;
      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });

    // Check initial link (cold start) and subscribe to further incoming links
    AppLinks().getInitialLink().then((uri) async {
      if (uri != null) await _handleIncomingUri(uri);
    }).catchError((_) {});

    _sub = AppLinks().uriLinkStream.listen((Uri uri) async {
      await _handleIncomingUri(uri);
    }, onError: (err) {
      // ignore errors from uri link stream; they don't block the flow
    });
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    try {
      // Use dynamic to avoid compile-time dependency on exact SDK helper names.
      final auth = Supabase.instance.client.auth as dynamic;
      // Try common method signatures (string or Uri). Many SDK versions
      // expose getSessionFromUrl or similar helper; attempt both.
      try {
        await auth.getSessionFromUrl(uri.toString());
      } catch (_) {
        try {
          await auth.getSessionFromUrl(uri);
        } catch (_) {
          // If the SDK doesn't provide that helper, ignore and just
          // fall back to checking currentUser below.
        }
      }
    } catch (_) {
      // Ignore reflection/failure — we'll still check currentUser below.
    }

    final user = _authService.currentUser;
    if (user != null && mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When the app resumes (user returns from browser), check if the auth session was created.
    if (state == AppLifecycleState.resumed) {
      // Start a short-lived poll to detect the session if it's created during resume.
      _pollForSessionOnResume();
    }
  }

  void _pollForSessionOnResume() {
    _pollTimer?.cancel();
    const duration = Duration(milliseconds: 500);
    int attempts = 0;
    const maxAttempts = 10; // ~5 seconds
    _pollTimer = Timer.periodic(duration, (t) {
      attempts++;
      final user = _authService.currentUser;
      if (user != null) {
        t.cancel();
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      } else if (attempts >= maxAttempts) {
        t.cancel();
      }
    });
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter both email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Color(0xFF388E3C),
          ),
        );
        final userId = response.user!.id;
        final complete = await ProfileService().isProfileComplete(userId);
        final target = complete ? const HomeScreen() : const AccountSetupScreen();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => target),
        );
      } else {
        _showError('Login failed. Please check your credentials.');
      }
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
            Icon(Icons.home, color: AppTheme.colorDarkerBrown, size: 28),
            const SizedBox(width: 8),
            Text('HostMe',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.colorDarkerBrown)),
                    ],
                  ),
                  const SizedBox(height: 24),
          Text('Welcome Back!',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.colorDarkerBrown)),
                  const SizedBox(height: 8),
          Text('Log in to find your perfect roommate and place.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.colorLightest)),
                  const SizedBox(height: 24),

                  // Email
                  Text('Email or Username', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.colorDarkerBrown)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter your email or username',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  Text('Password', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.colorDarkerBrown)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter your password',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Forgot Password?', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: primary)),
                    ),
                  ),

                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colorDarkerBrown,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('Log In', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),

                  const SizedBox(height: 20),
                  // Divider
                  Row(children: [const Expanded(child: Divider()), const SizedBox(width: 8), Text('Or log in with', style: GoogleFonts.plusJakartaSans(color: AppTheme.colorLightest)), const SizedBox(width: 8), const Expanded(child: Divider())]),
                  const SizedBox(height: 16),

                  // Social buttons - Native Google Sign-In
                  OutlinedButton(
                    onPressed: _isLoading ? null : () async {
                      setState(() => _isLoading = true);
                      try {
                        final response = await _authService.signInWithGoogleNative();
                        if (!mounted) return;
                        
                        if (response.user != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Google sign-in successful!'),
                              backgroundColor: Color(0xFF388E3C),
                            ),
                          );
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                        } else {
                          _showError('Google sign-in failed. Please try again.');
                        }
                      } catch (e) {
                        if (mounted) {
                          _showError('Google sign-in error: ${e.toString()}');
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SvgPicture.asset('assets/images/google_logo.svg', width: 20, height: 20),
                      const SizedBox(width: 8),
                      Text('Continue with Google', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.colorDarkest)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.apple, size: 20),
                      const SizedBox(width: 8),
                      Text('Continue with Apple', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.colorDarkest)),
                    ]),
                  ),

                  const SizedBox(height: 20),
                  
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: GoogleFonts.plusJakartaSans(color: AppTheme.colorLightest)),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                            child: Text('Sign Up', style: GoogleFonts.plusJakartaSans(color: primary, fontWeight: FontWeight.w700)),
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
    );
  }
}
