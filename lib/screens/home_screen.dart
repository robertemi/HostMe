import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/hero_section.dart';
import '../widgets/segmented_two_choice.dart';
import '../widgets/info_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authService = AuthService();
  int selectedChoice = 0; // 0 = Find a Roommate, 1 = Find a Place
  int navIndex = 0; // 0 = Home

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
        onTap: (i) {
          setState(() => navIndex = i);
          // TODO: Wire up navigation to other screens when available
        },
      ),
      body: HeroSection(
        // If you add a background asset, pass it via: backgroundImage: AssetImage('assets/your_image.jpg')
        backgroundImage: AssetImage('assets/Final-housing-for-all-pillar.jpg'),
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
                    onPressed: () {
                      // TODO: Hook up to search flow based on selectedChoice
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            selectedChoice == 0
                                ? 'Searching for roommates...'
                                : 'Searching for places...',
                          ),
                        ),
                      );
                    },
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
// --- IGNORE ---