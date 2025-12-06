import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/home_screen_widgets/hero_section.dart';
import '../widgets/home_screen_widgets/segmented_two_choice.dart';
import '../widgets/home_screen_widgets/info_card.dart';
import '../widgets/home_screen_widgets/primary_button.dart';
import 'login_screen.dart';
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

  Future<void> _onSearch() async {
    if (selectedChoice == 1) {
      // 🏠 "Find a Place" → user is looking for a room/house
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RoommateFinderScreen(searchMode: 'find_place'),
        ),
      );
    } else {
      // 👥 "Find a Roommate" → user is a host looking for a roommate
      // First, check if the user has a house registered
      try {
        final profile = await authService.getUserProfile();
        final hasHouse = profile != null && profile['house_id'] != null;
        
        if (!hasHouse) {
          if (!mounted) return;
          _showNoHouseDialog();
          return;
        }
        
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RoommateFinderScreen(searchMode: 'find_roommate'),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking profile: $e')),
        );
      }
    }
  }

  void _showNoHouseDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          icon: Icon(
            Icons.home_work_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('No Property Listed'),
          content: const Text(
            'To find a roommate, you need to list your property first. '
            'Add your house or apartment so potential roommates can see where they\'d be living!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _onListProperty();
              },
              icon: const Icon(Icons.add_home),
              label: const Text('List Property'),
            ),
          ],
        );
      },
    );
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
      // Paint the body behind the AppBar so the hero overlay covers the
      // same area as the AppBar (keeps header darkness consistent)
      extendBodyBehindAppBar: true,
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
      // Bottom nav handled by RootShell when present
      body: HeroSection(
        title: 'Welcome to Student Housing',
        subtitle: 'Find your perfect match for roommates and housing.',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  SegmentedTwoChoice(
                    leftLabel: 'Find a Roommate',
                    rightLabel: 'Find a Place',
                    selectedIndex: selectedChoice,
                    onChanged: (i) => setState(() => selectedChoice = i),
                  ),
                  const SizedBox(height: 16),

                  // Animated content area: switches between roommate view and place view
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final inAnim = Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.easeOutCubic))
                          .animate(animation);
                      return SlideTransition(
                        position: inAnim,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: selectedChoice == 0
                        ? Column(
                            key: const ValueKey('roommate'),
                            children: [
                              const InfoCard(
                                icon: Icons.group,
                                text:
                                    "Looking for a compatible roommate? We'll match you based on preferences, habits and budget.",
                              ),
                              const SizedBox(height: 16),
                              PrimaryPillButton(
                                label: 'Search Roommates',
                                onPressed: _onSearch,
                              ),
                            ],
                          )
                        : Column(
                            key: const ValueKey('place'),
                            children: [
                              const InfoCard(
                                icon: Icons.home,
                                text:
                                    "Searching for a place? Browse available listings or post your preferences to get matched with rooms and houses.",
                              ),
                              const SizedBox(height: 16),
                              PrimaryPillButton(
                                label: 'Search Places',
                                onPressed: _onSearch,
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 16),
                  // 🏡 New Button to list a property
                  ElevatedButton.icon(
                    onPressed: _onListProperty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
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
