import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _tokenCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _message;

  Future<void> _submit() async {
    final token = _tokenCtrl.text.trim();
    final pass = _passwordCtrl.text;
    final pass2 = _passwordConfirmCtrl.text;

    if (token.isEmpty || token.length != 6) {
      setState(() => _message = 'Please enter the 6-digit code from your email.');
      return;
    }

    if (pass.isEmpty || pass2.isEmpty) {
      setState(() => _message = 'Please enter and confirm your new password.');
      return;
    }

    if (pass != pass2) {
      setState(() => _message = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final verifyUrl =
          Uri.parse('${SupabaseConfig.supabaseUrl}/auth/v1/verify');

      final verifyResp = await http.post(
        verifyUrl,
        headers: {
          'Content-Type': 'application/json',
          'apikey': SupabaseConfig.supabaseAnonKey,
        },
        body: jsonEncode({
          'type': 'recovery',
          'token': token,
          'email': widget.email,
        }),
      );

      if (verifyResp.statusCode != 200) {
        setState(() => _message = 'Invalid or expired reset code.');
        return;
      }

      final verified = jsonDecode(verifyResp.body) as Map<String, dynamic>;
      final accessToken = verified['access_token'] as String?;

      if (accessToken == null || accessToken.isEmpty) {
        setState(() => _message = 'Failed to authenticate reset request.');
        return;
      }

      final updateUrl =
          Uri.parse('${SupabaseConfig.supabaseUrl}/auth/v1/user');

      final updateResp = await http.put(
        updateUrl,
        headers: {
          'Content-Type': 'application/json',
          'apikey': SupabaseConfig.supabaseAnonKey,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'password': pass}),
      );

      if (updateResp.statusCode == 200) {
        setState(() {
          _isSuccess = true;
          _message = 'Password updated successfully.';
        });
      } else {
        setState(() => _message = 'Failed to update password.');
      }
    } catch (e) {
      setState(() => _message = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Set New Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the 6-digit code sent to your email and choose a new password.',
              ),
              const SizedBox(height: 16),

              // Reset code
              TextField(
                controller: _tokenCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '6-digit reset code',
                ),
              ),
              const SizedBox(height: 16),

              // New password
              TextField(
                controller: _passwordCtrl,
                obscureText: !_showPassword,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'New password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Confirm password
              TextField(
                controller: _passwordConfirmCtrl,
                obscureText: !_showPassword,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Set password'),
                ),
              ),

              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(_message!),
              ],

              if (_isSuccess) ...[
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                        (_) => false,
                      );
                    },
                    child: const Text('Back to Login'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
