import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/roommate_finder_widgets/simple_top_bar.dart';
import '../widgets/roommate_finder_widgets/roommate_profile_card.dart';
import '../widgets/roommate_finder_widgets/roommate_action_bar.dart';
import '../services/matching_service.dart';
import '../models/match_result.dart';

class RoommateFinderScreen extends StatefulWidget {
  const RoommateFinderScreen({super.key});

  @override
  State<RoommateFinderScreen> createState() => _RoommateFinderScreenState();
}

class _RoommateFinderScreenState extends State<RoommateFinderScreen> {
  final MatchingService _matchingService = MatchingService();
  List<MatchResult> _matches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    try {
      final matches = await _matchingService.getSmartMatches();
      if (mounted) {
        setState(() {
          _matches = matches;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: SimpleTopBar(
        title: 'Smart Match',
        onLeadingTap: () {
          // TODO: Navigate to Home
        },
        onTrailingTap: () {
          // TODO: Open filters
        },
      ),
      body: SafeArea(
        top: false,
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading matches', style: theme.textTheme.titleMedium),
            TextButton(onPressed: _loadMatches, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No matches found yet.',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your profile preferences.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // For now, just show the top match. 
    // In a real app, you'd use a Swiper controller to iterate through _matches.
    final topMatch = _matches.first;

    // Determine image to show: House image (if available) or User Avatar
    final displayImage = topMatch.houseImage ?? topMatch.avatarUrl;
    
    // Build tags list from profile data
    final tags = <String>[];
    if (topMatch.occupation != null) tags.add(topMatch.occupation!);
    if (topMatch.gender != null) tags.add(topMatch.gender!);
    // Add compatibility highlights
    if (topMatch.budgetScore > 80) tags.add('Budget Match');
    if (topMatch.lifestyleScore > 80) tags.add('Lifestyle Match');

    return Column(
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
                      // Tilted background card (decoration)
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
                      // The Swipeable Profile Card
                      Dismissible(
                        key: ValueKey(topMatch.userId),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) {
                          final isLike = direction == DismissDirection.startToEnd;
                          _handleSwipe(topMatch, isLike);
                        },
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 32),
                          child: const Icon(Icons.favorite, color: Colors.white, size: 48),
                        ),
                        secondaryBackground: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 32),
                          child: const Icon(Icons.close, color: Colors.white, size: 48),
                        ),
                        child: RoommateProfileCard(
                          name: topMatch.fullName ?? 'Unknown',
                          age: topMatch.age ?? 0,
                          bio: topMatch.bio ?? 'No bio available.',
                          tags: tags,
                          imageUrl: displayImage, // Use URL from DB
                          matchScore: topMatch.matchScore,
                          rentPrice: topMatch.houseRent,
                        ),
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
          onNope: () => _triggerSwipe(false),
          onSuperLike: () {
            // TODO: Handle "Super Like" action
          },
          onLike: () => _triggerSwipe(true),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _triggerSwipe(bool isLike) {
    if (_matches.isEmpty) return;
    // Programmatically dismiss (not easily supported by Dismissible without a controller, 
    // so we just manually call the handler and remove from list for now)
    _handleSwipe(_matches.first, isLike);
  }

  Future<void> _handleSwipe(MatchResult match, bool isLike) async {
    // 1. Optimistically remove from UI
    setState(() {
      _matches.remove(match);
    });

    try {
      // 2. Send to Backend
      final isMutualMatch = await _matchingService.swipeUser(match.userId, isLike);

      // 3. If Mutual Match, show Dialog!
      if (isMutualMatch && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('It\'s a Match! 🎉'),
            content: Text('You and ${match.fullName} liked each other!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep Swiping'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to Chat
                },
                child: const Text('Send Message'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Revert on error? Or just show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving swipe: $e')),
        );
      }
    }
  }
}
