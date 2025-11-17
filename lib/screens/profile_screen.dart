import 'package:flutter/material.dart';
import 'package:host_me/widgets/common/app_bottom_nav_bar.dart';
import 'package:host_me/widgets/profile_screen_widgets/profile_header.dart';
import 'package:host_me/widgets/profile_screen_widgets/profile_avatar_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/profile_progress_bar.dart';
import 'package:host_me/widgets/profile_screen_widgets/interests_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/activity_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/preferences_section.dart';
import 'home_screen.dart';
import 'houses_screen.dart';
import 'matches_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Values displayed in PreferencesSection (initialized from Supabase profile)
  double budget = 3; // 1..5 category derived from budgetMin/Max
  double cleanliness = 3;
  double noise = 3;
  bool smoking = false;
  bool pets = false;

  ProfileModel? _profile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final fetched = await ProfileService().fetchProfile(user.id);
      setState(() {
        _profile = fetched;
        // Map DB values to UI
        cleanliness = (fetched?.cleanlinessLevel ?? 3).toDouble();
        noise = (fetched?.noiseLevel ?? 3).toDouble();
        smoking = fetched?.smokingPreference ?? false;
        pets = fetched?.petsPreference ?? false;
        budget = _computeBudgetLevel(fetched?.budgetMin, fetched?.budgetMax);
        _loadingProfile = false;
      });
    } else {
      setState(() => _loadingProfile = false);
    }
  }

  double _computeBudgetLevel(int? min, int? max) {
    if (min == null && max == null) return 3;
    final values = [
      if (min != null) min.toDouble(),
      if (max != null) max.toDouble(),
    ];
    final v = values.isEmpty ? 0 : (values.reduce((a, b) => a + b) / values.length);
    // Match labels in PreferencesSection (EUR): <100, 100-300, 300-500, 500-1000, >1000
    if (v <= 100) return 1;
    if (v <= 300) return 2;
    if (v <= 500) return 3;
    if (v <= 1000) return 4;
    return 5;
  }

  void _onNavTap(int index) {
    if (index == 3) return; // already on profile
    Widget target;
    switch (index) {
      case 0:
        target = const HomeScreen();
        break;
      case 1:
        target = const HousesScreen();
        break;
      case 2:
      default:
        target = const MatchesScreen();
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => target),
    );
  }
// TODO: Implement onBack and onEdit callbacks in ProfileHeader
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const ProfileHeader(
        onBack: null,
        onEdit: null,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: _onNavTap,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Avatar + Bio ---
            if (_loadingProfile)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: ProfileAvatarSection(
                  imageUrl: _profile?.avatarUrl ?? "",
                  name: _profile?.fullName ?? 'Your Name',
                  bio: _profile != null
                      ? 'Occupation: ${_profile!.occupation ?? 'N/A'}'
                      : 'Complete your profile to personalize this section.',
                ),
              ),
            const SizedBox(height: 20),

            // --- Progress bar ---
            const ProfileProgressBar(percent: 0.75),
            const SizedBox(height: 20),

            // --- Interests ---
            const InterestsSection(),
            const SizedBox(height: 24),

            // --- Preferences ---
            PreferencesSection(
              budgetLevel: budget,
              onBudgetChanged: (v) => setState(() => budget = v),
              cleanlinessLevel: cleanliness,
              onCleanlinessChanged: (v) => setState(() => cleanliness = v),
              noiseLevel: noise,
              onNoiseChanged: (v) => setState(() => noise = v),
              smoking: smoking,
              onSmokingChanged: (v) => setState(() => smoking = v),
              pets: pets,
              onPetsChanged: (v) => setState(() => pets = v)
            ),

            const SizedBox(height: 28),

            // --- Activity Section ---
            const ActivitySection(),
            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }
}
