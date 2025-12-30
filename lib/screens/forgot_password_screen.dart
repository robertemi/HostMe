import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'reset_password_screen.dart';
import '../utils/notifications.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  Future<void> _sendResetLink() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      await showAppError(context, 'Please enter your email');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Use path redirect (no '#') so Supabase returns tokens to /reset-password
      String? redirectTo;
      if (kIsWeb) {
        // Use the Edge Function URL (configured in SupabaseConfig) for web.
        redirectTo = SupabaseConfig.resetPasswordRedirect;
      } else if (SupabaseConfig.resetPasswordRedirect.isNotEmpty) {
        // For mobile, you can also configure a deep-link in SupabaseConfig.
        redirectTo = SupabaseConfig.resetPasswordRedirect;
      }
      await Supabase.instance.client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);

      setState(() {
        _isSuccess = true;
        _message = 'Check your email for the password reset link!';
      });
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _message = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendResetLink,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Reset Link'),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSuccess ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _isSuccess ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ),
            ],
            if (_isSuccess) ...[
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    final email = _emailCtrl.text.trim();

                    if (email.isEmpty) {
                      // optional: show error/snackbar
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ResetPasswordScreen(email: email),
                      ),
                    );
                  },
                  child: const Text('Open Reset Screen (paste token)'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}