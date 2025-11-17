import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/home_screen_widgets/hero_section.dart';
import '../widgets/home_screen_widgets/segmented_two_choice.dart';
import '../widgets/home_screen_widgets/info_card.dart';
import '../widgets/home_screen_widgets/primary_button.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'login_screen.dart';
import 'houses_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import 'roommate_finder_screen.dart';
import 'add_house_screen.dart'; // 🆕 import the new screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authService = AuthService();
  int selectedChoice = 0; // 0 = Find a Roommate, 1 = Find a Place
  int navIndex = 0; // 0 = Home

  void _onNavTap(int i) {
    if (i == navIndex) return;
    Widget target;
    switch (i) {
      case 0:
        target = const HomeScreen();
        break;
      case 1:
        target = const MatchesScreen();
        break;
      case 2:
      default:
        target = const ProfileScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => target),
    );
  }

  void _onSearch() {
    if (selectedChoice == 1) {
      // 🏠 “Find a Place” → go to HousesScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HousesScreen()),
      );
    } else {
      // 👥 “Find a Roommate” → RoommateFinderScreen (or placeholder)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RoommateFinderScreen()),
      );
    }
  }

  void _onListProperty() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddHouseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'HostMe',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navIndex,
        onTap: _onNavTap,
      ),
      body: HeroSection(
        backgroundImage:
            const AssetImage('assets/Final-housing-for-all-pillar.jpg'),
        title: 'Welcome to Student Housing',
        subtitle: 'Find your perfect match for roommates and housing.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  SegmentedTwoChoice(
                    leftLabel: 'Find a Roommate',
                    rightLabel: 'Find a Place',
                    selectedIndex: selectedChoice,
                    onChanged: (i) => setState(() => selectedChoice = i),
                  ),
                  const SizedBox(height: 16),
                  const InfoCard(
                    icon: Icons.group,
                    text:
                        "Have a place and looking for roommates? We'll help you find the perfect match based on your preferences and lifestyle.",
                  ),
                  const SizedBox(height: 16),
                  PrimaryPillButton(
                    label: 'Search',
                    onPressed: _onSearch,
                  ),
                  const SizedBox(height: 16),
                  // 🏡 New Button to list a property
                  ElevatedButton.icon(
                    onPressed: _onListProperty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                    ),
                    icon: const Icon(Icons.add_home),
                    label: const Text(
                      'List Your Property',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
