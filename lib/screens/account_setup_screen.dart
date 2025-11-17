import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';
import 'home_screen.dart';
import '../widgets/common/labeled_slider.dart';

class AccountSetupScreen extends StatefulWidget {
  const AccountSetupScreen({super.key});

  @override
  State<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends State<AccountSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();

  // Step management
  int _step = 0;
  static const int _totalSteps = 8;

  // Controllers / state
  final TextEditingController _avatarUrlCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  String? _gender; // male, female, prefer_not_to_say
  final TextEditingController _phoneCtrl = TextEditingController();
  String _countryCode = '+1';
  String? _occupation; // student, employee, unemployed, other
  final TextEditingController _universityCtrl = TextEditingController();
  final TextEditingController _budgetMinCtrl = TextEditingController();
  final TextEditingController _budgetMaxCtrl = TextEditingController();
  bool _submitting = false;

  // Preferences & DOB (mirroring Profile screen UI)
  bool _smoking = false;
  bool _pets = false;
  double _cleanliness = 3;
  double _noise = 3;
  DateTime? _dob;

  List<String> get _genders => [
        'Male',
        'Female',
        'Prefer not to say',
      ];

  List<Map<String, String>> get _countries => [
        {'name': 'US', 'code': '+1'},
        {'name': 'UK', 'code': '+44'},
        {'name': 'RO', 'code': '+40'},
        {'name': 'FR', 'code': '+33'},
        {'name': 'DE', 'code': '+49'},
      ];

  List<String> get _occupations => [
        'Student',
        'Employee',
        'Unemployed',
        'Other',
      ];

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    setState(() => _submitting = true);
    try {
      final profile = ProfileModel(
        id: user.id,
        email: user.email,
        avatarUrl: _avatarUrlCtrl.text.trim().isEmpty ? null : _avatarUrlCtrl.text.trim(),
        fullName: _nameCtrl.text.trim(),
        gender: _gender?.toLowerCase().replaceAll(' ', '_'),
        phone: '$_countryCode ${_phoneCtrl.text.trim()}',
        occupation: _occupation?.toLowerCase(),
        university: _universityCtrl.text.trim().isEmpty
            ? null
            : _universityCtrl.text.trim(),
        budgetMin: int.tryParse(_budgetMinCtrl.text.trim()),
        budgetMax: int.tryParse(_budgetMaxCtrl.text.trim()),
        smokingPreference: _smoking,
        petsPreference: _pets,
        cleanlinessLevel: _cleanliness.round(),
        noiseLevel: _noise.round(),
        dateOfBirth: _dob,
      );
      await _profileService.upsertProfile(profile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You're all set!")),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _centeredStep(
          title: "Let's add a profile picture",
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage: (_avatarUrlCtrl.text.trim().isNotEmpty)
                    ? NetworkImage(_avatarUrlCtrl.text.trim())
                    : null,
                child: _avatarUrlCtrl.text.trim().isEmpty
                    ? const Icon(Icons.person, size: 48)
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _avatarUrlCtrl,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Paste an image URL',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        );
      case 1:
        return _centeredStep(
          title: "What's your full name?",
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: TextFormField(
              controller: _nameCtrl,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: 'Full Name'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
          ),
        );
      case 2:
        return _centeredStep(
          title: 'What is your gender?',
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: _genders.map((g) {
              final selected = _gender == g;
              return ChoiceChip(
                label: Text(g),
                selected: selected,
                onSelected: (_) => setState(() => _gender = g),
              );
            }).toList(),
          ),
        );
      case 3:
        return _centeredStep(
          title: "What's your phone number?",
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    value: _countryCode,
                    items: _countries
                        .map((c) => DropdownMenuItem(
                              value: c['code'],
                              child: Text('${c['name']} (${c['code']})'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _countryCode = v ?? '+1'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 260,
                  child: TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: 'Phone Number'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
          ),
        );
      case 4:
        return _centeredStep(
          title: 'What is your current occupation?',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: _occupations.map((o) {
                  final selected = _occupation == o;
                  return FilterChip(
                    label: Text(o),
                    selected: selected,
                    onSelected: (_) => setState(() => _occupation = o),
                  );
                }).toList(),
              ),
              if (_occupation == 'Student') ...[
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: TextFormField(
                    controller: _universityCtrl,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: 'University (optional)'),
                  ),
                ),
              ]
            ],
          ),
        );
      case 5:
        return _centeredStep(
          title: 'What is your budget range?',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _budgetMinCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: 'Min'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _budgetMaxCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: 'Max'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
          ),
        );
      case 6:
        return _centeredStep(
          title: 'What are your preferences?',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cleanliness draggable (1..5)
              const Text('Cleanliness'),
              SizedBox(
                width: 420,
                child: LabeledSlider(
                  min: 1,
                  max: 5,
                  value: _cleanliness,
                  onChanged: (v) => setState(() => _cleanliness = v),
                  labels: const ['Very Messy','Messy','Average','Tidy','Very Tidy'],
                ),
              ),
              const SizedBox(height: 12),
              // Noise draggable (1..5)
              const Text('Noise Level'),
              SizedBox(
                width: 420,
                child: LabeledSlider(
                  min: 1,
                  max: 5,
                  value: _noise,
                  onChanged: (v) => setState(() => _noise = v),
                  labels: const ['Very Quiet','Quiet','Moderate','Lively','Very Loud'],
                ),
              ),
              const SizedBox(height: 16),
              // Toggles like Profile screen
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    const Text('Smoking'),
                    Switch(value: _smoking, onChanged: (v) => setState(() => _smoking = v)),
                  ]),
                  const SizedBox(width: 24),
                  Row(children: [
                    const Text('Pets'),
                    Switch(value: _pets, onChanged: (v) => setState(() => _pets = v)),
                  ]),
                ],
              ),
            ],
          ),
        );
      case 7:
      default:
        return _centeredStep(
          title: "What's your date of birth?",
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _dob == null ? 'Not selected' : _dob!.toIso8601String().split('T').first,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(now.year - 20, now.month, now.day),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(now.year - 16, now.month, now.day),
                  );
                  if (picked != null) setState(() => _dob = picked);
                },
                icon: const Icon(Icons.cake_outlined),
                label: const Text('Select Date'),
              ),
            ],
          ),
        );
    }
  }

  // Centered step wrapper: big title + centered child
  Widget _centeredStep({required String title, required Widget child}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }

  // Removed chip groups; using sliders + toggles to mirror Profile UI.

  bool _canProceedCurrentStep() {
    switch (_step) {
      case 0:
        // Avatar is optional; let them proceed
        return true;
      case 1:
        return _nameCtrl.text.trim().isNotEmpty;
      case 2:
        return _gender != null;
      case 3:
        return _phoneCtrl.text.trim().isNotEmpty;
      case 4:
        // If student, university optional for now
        return _occupation != null;
      case 5:
        return _budgetMinCtrl.text.trim().isNotEmpty &&
            _budgetMaxCtrl.text.trim().isNotEmpty;
      case 6:
        // Preferences are optional
        return true;
      case 7:
        // DOB optional
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Setup')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: _buildStepContent(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    if (_step > 0)
                      OutlinedButton(
                        onPressed: _back,
                        child: const Text('Back'),
                      ),
                    const Spacer(),
                    if (_step < _totalSteps - 1)
                      ElevatedButton(
                        onPressed: _canProceedCurrentStep() ? _next : null,
                        child: const Text('Next'),
                      )
                    else
                      ElevatedButton(
                        onPressed: _canProceedCurrentStep() && !_submitting ? _submit : null,
                        child: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Finish'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
