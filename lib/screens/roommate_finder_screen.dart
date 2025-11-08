import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/roommate_finder_widgets/simple_top_bar.dart';
import '../widgets/roommate_finder_widgets/roommate_profile_card.dart';
import '../widgets/roommate_finder_widgets/roommate_action_bar.dart';

/// Roommate Finder screen UI based on `mockups/roommateScreen.html`.
///
/// NOTE:
/// - Navigation (home/filter) and swipe/action behaviors are TODOs.
/// - Data is mocked; later replace with real profiles and images from DB.
class RoommateFinderScreen extends StatelessWidget {
  const RoommateFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: SimpleTopBar(
        title: 'Roomie Finder',
        onLeadingTap: () {
          // TODO: Navigate to Home
        },
        onTrailingTap: () {
          // TODO: Open filters
        },
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.68,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Tilted background card
                          Transform.rotate(
                            angle: -4 * (math.pi / 180),
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          RoommateProfileCard(
                            name: 'Sarah',
                            age: 21,
                            bio:
                                'Creative soul looking for a chill and respectful roommate.',
                            tags: const ['Art', 'Clean', 'Night Owl', 'Pet-Friendly'],
                            imageAsset: 'assets/Final-housing-for-all-pillar.jpg',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            RoommateActionBar(
              onNope: () {
                // TODO: Handle "Nope" action
              },
              onSuperLike: () {
                // TODO: Handle "Super Like" action
              },
              onLike: () {
                // TODO: Handle "Like" action
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
