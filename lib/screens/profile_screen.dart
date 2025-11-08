import 'package:flutter/material.dart';
import 'package:host_me/widgets/app_bottom_nav_bar.dart';
import 'package:host_me/widgets/profile_screen_widgets/profile_header.dart';
import 'package:host_me/widgets/profile_screen_widgets/profile_avatar_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/profile_progress_bar.dart';
import 'package:host_me/widgets/profile_screen_widgets/interests_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/preferences_section.dart';
import 'package:host_me/widgets/profile_screen_widgets/activity_section.dart';
import 'home_screen.dart';
import 'houses_screen.dart';
import 'matches_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Local state for demo only; these would come from a profile model later
  int lookingFor = 0;
  double budget = 1000;
  bool smoking = false;
  bool pets = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const ProfileHeader(),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: _onNavTap,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ProfileAvatarSection(
                imageUrl:
                    'https://i.pravatar.cc/300?img=11',
                name: 'Alex Doe',
                age: 22,
                bio:
                    'Aspiring software engineer and avid hiker. Looking for a clean and quiet place to live with like-minded individuals.',
              ),
            ),
            const SizedBox(height: 20),
            const ProfileProgressBar(percent: 0.75),
            const SizedBox(height: 20),
            Row(
              children: [
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
              ],
            ),
            const SizedBox(height: 24),
            PreferencesSection(
              lookingForIndex: lookingFor,
              onLookingForChanged: (i) => setState(() => lookingFor = i),
              budgetMin: 500,
              budgetMax: 1500,
              budgetValue: budget,
              onBudgetChanged: (v) => setState(() => budget = v),
              cleanlinessLabel: 'Very Tidy',
              cleanlinessPercent: 0.83,
              noiseLabel: 'Quiet',
              noisePercent: 0.17,
              smoking: smoking,
              onSmokingChanged: (v) => setState(() => smoking = v),
              pets: pets,
              onPetsChanged: (v) => setState(() => pets = v),
            ),
            const SizedBox(height: 28),
            const ActivitySection(),
            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }
}
