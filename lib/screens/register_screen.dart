import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // Password validation state
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  double _passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      // Calculate strength (0.0 to 1.0)
      int metRequirements = 0;
      if (_hasMinLength) metRequirements++;
      if (_hasUppercase) metRequirements++;
      if (_hasLowercase) metRequirements++;
      if (_hasNumber) metRequirements++;
      if (_hasSpecialChar) metRequirements++;
      _passwordStrength = metRequirements / 5.0;
    });
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
                  Text('Welcome!', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.colorDarkerBrown)),
                  const SizedBox(height: 8),
                  Text('Create an account to get started.', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.colorLightest)),
                  const SizedBox(height: 24),

                  Text('Full name', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.colorDarkerBrown)),
                  const SizedBox(height: 8),
                  TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Your full name')),
                  const SizedBox(height: 16),

                  Text('Email', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.colorDarkerBrown)),
                  const SizedBox(height: 8),
                  TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Enter your email')),
                  const SizedBox(height: 16),

                  Text('Password', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.colorDarkerBrown)),
                  const SizedBox(height: 8),
                  TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(hintText: 'Create a password')),
                  const SizedBox(height: 12),
                  
                  // Password strength indicator
                  if (_passwordController.text.isNotEmpty) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _passwordStrength,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _passwordStrength < 0.4 ? const Color(0xFFD32F2F) :
                                    _passwordStrength < 0.7 ? const Color(0xFFF57C00) :
                                    const Color(0xFF388E3C),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _passwordStrength < 0.4 ? 'Weak' :
                              _passwordStrength < 0.7 ? 'Medium' : 'Strong',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _passwordStrength < 0.4 ? const Color(0xFFD32F2F) :
                                       _passwordStrength < 0.7 ? const Color(0xFFF57C00) :
                                       const Color(0xFF388E3C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildRequirement('At least 8 characters', _hasMinLength),
                        _buildRequirement('One uppercase letter', _hasUppercase),
                        _buildRequirement('One lowercase letter', _hasLowercase),
                        _buildRequirement('One number', _hasNumber),
                        _buildRequirement('One special character', _hasSpecialChar),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  const SizedBox(height: 8),

                  Text('Confirm password', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.colorDarkerBrown)),
                  const SizedBox(height: 8),
                  TextField(controller: _confirmController, obscureText: true, decoration: const InputDecoration(hintText: 'Confirm your password')),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      // TODO: registration logic
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.colorDarkerBrown, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text('Create account', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),

                  const SizedBox(height: 12),
                  Center(child: Text('By creating an account you agree to our Terms.', style: GoogleFonts.plusJakartaSans(color: AppTheme.colorLightest, fontSize: 12), textAlign: TextAlign.center)),
                  const SizedBox(height: 12),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text("Already have an account? ", style: GoogleFonts.plusJakartaSans(color: AppTheme.colorDarkerBrown)),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Sign In', style: GoogleFonts.plusJakartaSans(color: primary, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? const Color(0xFF388E3C) : const Color(0xFFBDBDBD),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isMet ? AppTheme.colorDarkerBrown : primary,
              decoration: isMet ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}
