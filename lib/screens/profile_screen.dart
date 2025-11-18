import 'package:flutter/material.dart';
// Bottom navigation moved to RootShell
import 'package:host_me/widgets/profile_screen_widgets/profile_header.dart';
import 'package:host_me/widgets/profile_screen_widgets/profile_avatar_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/profile_progress_bar.dart';
import 'package:host_me/widgets/profile_screen_widgets/interests_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/activity_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/preferences_section.dart';
// navigation handled by RootShell

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Local state (later these will come from your Supabase profile)
  double budget = 3;
  double cleanliness = 4;
  double noise = 2;
  bool smoking = false;
  bool pets = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const ProfileHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Avatar + Bio ---
            Center(
              child: ProfileAvatarSection(
                imageUrl: 'https://i.pravatar.cc/300?img=11',
                name: 'Alex Doe',
                age: 22,
                bio:
                    'Aspiring software engineer and avid hiker. Looking for a clean and quiet place to live with like-minded individuals.',
              ),
            ),
            const SizedBox(height: 20),

            // --- Progress bar ---
            const ProfileProgressBar(percent: 0.75),
            const SizedBox(height: 20),

            // --- Interests ---
            InterestsSection(
              interests: const [
                'Music',
                'Sports',
                'Gaming',
                'Hiking',
                'Cooking',
                'Traveling',
              ],
              highlighted: const {'Music', 'Gaming', 'Hiking'},
            ),
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
