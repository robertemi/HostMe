import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/supabase_config.dart';
import 'login_screen.dart';

// // For mobile deep links we'll use `uni_links`. This import is optional on web.
// // Add `uni_links` in pubspec.yaml and platform setup for Android/iOS.
// import 'package:uni_links/uni_links.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  String? _token;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _message;

  @override
  void initState() {
    super.initState();
  }
  // No automatic URL parsing. Users must paste the token from the email.

  Future<void> _submit() async {
    final pass = _passwordCtrl.text;
    final pass2 = _passwordConfirmCtrl.text;
    if (pass.isEmpty || pass2.isEmpty) {
      setState(() => _message = 'Please enter a new password and confirm it.');
      return;
    }
    if (pass != pass2) {
      setState(() => _message = 'Passwords do not match.');
      return;
    }
    // prefer manual token field if provided
    final usedToken = (_tokenCtrl.text.isNotEmpty) ? _tokenCtrl.text : (_token ?? '');
    if (usedToken.trim().isEmpty) {
      setState(() => _message = 'Missing reset token. Paste the token from the email.');
      return;
    }

    // Normalize token: only trim surrounding whitespace and remove internal newlines/spaces.
    // No URL/fragment parsing or percent-decoding — user must paste the clean token.
    String normalized = usedToken.trim();
    // Remove whitespace and common invisible characters (zero-width spaces, BOM) which may be present
    normalized = normalized.replaceAll(RegExp(r'\s+'), '');
    normalized = normalized.replaceAll(RegExp(r'[\u200B\u200C\u200D\uFEFF]'), '');

    // OTP: 6-digit numeric code (e.g. "123456")
    final isOtp = RegExp(r'^\d{6}$').hasMatch(normalized);
    final isJwt = normalized.split('.').length == 3;

    if (!isOtp && !isJwt) {
      final cp = normalized.runes.map((r) => r.toRadixString(16).padLeft(2, '0')).join(' ');
      setState(() => _message = 'Token looks invalid. Normalized: "$normalized" (len=${normalized.length})\ncodepoints: $cp');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      if (isOtp) {
        // OTP flow (recovery): require email and call the REST /verify endpoint to exchange the 6-digit code
        // for an access token, then use that access token to update the user's password.
        final email = _emailCtrl.text.trim();
        if (email.isEmpty) {
          setState(() => _message = 'Please enter the email associated with this account.');
          return;
        }

        final verifyUrl = Uri.parse('${SupabaseConfig.supabaseUrl}/auth/v1/verify');
        final verifyResp = await http.post(
          verifyUrl,
          headers: {
            'Content-Type': 'application/json',
            'apikey': SupabaseConfig.supabaseAnonKey,
          },
          body: jsonEncode({'type': 'recovery', 'token': normalized, 'email': email}),
        );

        if (verifyResp.statusCode != 200) {
          setState(() => _message = 'Failed to verify token: ${verifyResp.statusCode} ${verifyResp.body}');
          return;
        }

        final verified = jsonDecode(verifyResp.body) as Map<String, dynamic>;
        final accessToken = verified['access_token'] as String?;
        if (accessToken == null || accessToken.isEmpty) {
          setState(() => _message = 'Failed to verify token: no access token returned.');
          return;
        }

        // Use the returned access token to PUT /auth/v1/user and change the password
        final url = Uri.parse('${SupabaseConfig.supabaseUrl}/auth/v1/user');
        final resp = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'apikey': SupabaseConfig.supabaseAnonKey,
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({'password': pass}),
        );

        if (resp.statusCode == 200) {
          setState(() {
            _isSuccess = true;
            _message = 'Password updated. You can now login with your new password.';
          });
        } else {
          setState(() {
            _isSuccess = false;
            _message = 'Failed to update password: ${resp.statusCode} ${resp.body}';
          });
        }
      } else {
        // JWT flow: existing behavior — put /auth/v1/user with the access token
        final url = Uri.parse('${SupabaseConfig.supabaseUrl}/auth/v1/user');
        final resp = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'apikey': SupabaseConfig.supabaseAnonKey,
            'Authorization': 'Bearer $normalized',
          },
          body: jsonEncode({'password': pass}),
        );

        if (resp.statusCode == 200) {
          setState(() {
            _isSuccess = true;
            _message = 'Password updated. You can now login with your new password.';
          });
        } else {
          setState(() {
            _isSuccess = false;
            _message = 'Failed to update password: ${resp.statusCode} ${resp.body}';
          });
        }
      }
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
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set New Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the email (if you received a 6-digit code), the reset token (from email) and your new password'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email (required for 6-digit code)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tokenCtrl,
              decoration: const InputDecoration(labelText: 'Reset token (paste here)'),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordConfirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm password'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Set password'),
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
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Back to Login'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
