import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/roommate_finder_widgets/simple_top_bar.dart';
import '../widgets/roommate_finder_widgets/roommate_profile_card.dart';
import '../widgets/roommate_finder_widgets/roommate_action_bar.dart';
import '../widgets/roommate_finder_widgets/swipeable_card.dart';
import '../services/matching_service.dart';
import '../models/match_result.dart';
import './property_detail_screen.dart'; // <-- Make sure this exists
import '../services/house_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoommateFinderScreen extends StatefulWidget {
  /// The search mode: 'find_place' (user looking for a room) or 'find_roommate' (host looking for a roommate).
  final String searchMode;

  const RoommateFinderScreen({
    super.key,
    required this.searchMode,
  });

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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final matches = await _matchingService.getSmartMatches(widget.searchMode);
      if (!mounted) return;

      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: SimpleTopBar(
        title: 'Smart Match',
        onLeadingTap: () => Navigator.pop(context),
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
            TextButton(
              onPressed: _loadMatches,
              child: const Text('Retry'),
            ),
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
            Text('No matches found yet.', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your profile preferences.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // For now, use only top match
    final topMatch = _matches.first;

    // Image logic
    final String? displayImage;
    final String? hostAvatar;

    if (widget.searchMode == 'find_place') {
      displayImage = topMatch.houseImage ?? topMatch.avatarUrl;
      hostAvatar = topMatch.avatarUrl;
    } else {
      displayImage = topMatch.avatarUrl;
      hostAvatar = null;
    }

    // Build tags list
    final tags = <String>[];
    if (topMatch.occupation != null) tags.add(topMatch.occupation!);
    if (topMatch.gender != null) tags.add(topMatch.gender!);
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
                      // Rotated background card
                      Transform.rotate(
                        angle: -4 * (math.pi / 180),
                        child: Container(
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

                      // Swipeable Card WRAPPED IN A TAP HANDLER
                      GestureDetector(
                        onTap: () async {
                          final houseService = HouseService();
                          final currentUserId = Supabase.instance.client.auth.currentUser!.id;

                          // Decide who is the host for this match
                          late final String hostId;

                          if (widget.searchMode == 'find_place') {
                            // user is looking for place -> card shows HOSTS
                            hostId = topMatch.userId;
                          } else {
                            // user is host looking for roommates -> user owns house
                            hostId = currentUserId;
                          }

                          final house = await houseService.getHouseForHost(hostId);

                          if (house == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("This host has no property listed.")),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PropertyDetailScreen(
                                house: house,
                                host: topMatch 
                              ),
                            ),
                          );
                        },
                        child: SwipeableCard(
                          key: ValueKey(topMatch.userId),
                          onSwipeRight: () => _handleSwipe(topMatch, true),
                          onSwipeLeft: () => _handleSwipe(topMatch, false),
                          maxRotation: 30.0,
                          child: RoommateProfileCard(
                            name: topMatch.fullName ?? 'Unknown',
                            age: topMatch.age ?? 0,
                            bio: topMatch.bio ?? 'No bio available.',
                            tags: tags,
                            imageUrl: displayImage,
                            matchScore: topMatch.matchScore,
                            rentPrice: topMatch.houseRent,
                            houseAddress: topMatch.houseAddress,
                            hostAvatarUrl: hostAvatar,
                            searchMode: widget.searchMode,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        RoommateActionBar(
          onNope: () => _triggerSwipe(false),
          onSuperLike: () {
            // TODO: Handle "Super Like"
          },
          onLike: () => _triggerSwipe(true),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // Programmatic swipe handling
  void _triggerSwipe(bool isLike) {
    if (_matches.isEmpty) return;
    _handleSwipe(_matches.first, isLike);
  }

  Future<void> _handleSwipe(MatchResult match, bool isLike) async {
    // Remove from UI immediately
    setState(() {
      _matches.remove(match);
    });

    try {
      // Send swipe to backend
      final isMutualMatch =
          await _matchingService.swipeUser(match.userId, isLike);

      // Mutual like popup
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
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving swipe: $e')),
      );
    }
  }
}
