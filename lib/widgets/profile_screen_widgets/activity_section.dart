import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/profile_service.dart';
import '../../models/profile_model.dart';
import '../../services/house_service.dart';
import '../../models/house_model.dart';
import '../../utils/notifications.dart';
import '../../models/match_result.dart';
import '../../screens/property_detail_screen.dart';
import 'profile_avatar_section.dart';
import 'interests_section.dart';
import 'preferences_section.dart';
import 'about_section.dart';

class ActivitySection extends StatefulWidget {
  const ActivitySection({super.key});

  @override
  State<ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends State<ActivitySection> {
  List<ProfileModel> _matches = [];
  List<ProfileModel> _swipes = [];
  List<House> _listedHouses = [];
  ProfileModel? _currentUserProfile;
  bool _loading = true;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final service = ProfileService();
      final houseService = HouseService();
      try {
        final matches = await service.getMatches(user.id);
        final swipes = await service.getSwipedProfiles(user.id);
        final houses = await houseService.getHousesForUser(user.id);
        final me = await service.fetchProfile(user.id);
        if (mounted) {
          setState(() {
            _matches = matches;
            _swipes = swipes;
            _listedHouses = houses;
            _currentUserProfile = me;
            _loading = false;
          });
        }
      } catch (e) {
        debugPrint('Error loading activity data: $e');
        if (mounted) setState(() => _loading = false);
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openHouseDetails(House house) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final host = MatchResult(
      userId: user.id,
      matchScore: 0,
      budgetScore: 0,
      lifestyleScore: 0,
      fullName: _currentUserProfile?.fullName ?? 'Host',
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(
          house: house,
          host: host,
          hostProfile: _currentUserProfile,
          hidePropertyTab: false,
          hideHostProfileTab: true,
        ),
      ),
    );
  }

  Future<void> _deleteHouse(House house) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete property?'),
        content: const Text('This will remove the listing from the database.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await HouseService().deleteHouse(houseId: house.id, userId: user.id);
      if (!mounted) return;
      setState(() {
        _listedHouses.removeWhere((h) => h.id == house.id);
      });
      await showAppSuccess(context, 'Property deleted');
    } catch (e) {
      if (!mounted) return;
      await showAppDetailedError(context, e, title: 'Failed to delete property');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        _Tabs(
          selectedIndex: _tabIndex,
          matchCount: _matches.length,
          onTabChanged: (index) => setState(() => _tabIndex = index),
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_tabIndex == 2)
          _ListedPropertiesList(
            houses: _listedHouses,
            onDelete: _deleteHouse,
            onOpen: _openHouseDetails,
          )
        else
          _MatchesGrid(
            profiles: _tabIndex == 0 ? _matches : _swipes,
          ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  final int selectedIndex;
  final int matchCount;
  final ValueChanged<int> onTabChanged;

  const _Tabs({
    required this.selectedIndex,
    required this.matchCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ['Matches', 'Past Swipes', 'Listed Properties'];
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: i == selectedIndex
                          ? Theme.of(context).primaryColor
                          : Colors.white24,
                      width: 2,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labels[i],
                      style: TextStyle(
                        color: i == selectedIndex ? Theme.of(context).primaryColor : Colors.white70,
                        fontWeight: i == selectedIndex ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (i == 0 && matchCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('$matchCount', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ListedPropertiesList extends StatelessWidget {
  final List<House> houses;
  final Future<void> Function(House house) onDelete;
  final Future<void> Function(House house) onOpen;

  const _ListedPropertiesList({required this.houses, required this.onDelete, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    if (houses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('No listed properties yet.', style: TextStyle(color: Colors.white54))),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: houses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final house = houses[i];
        final subtitleParts = <String>[];
        if (house.rent != null) subtitleParts.add('\$${house.rent!.toStringAsFixed(0)}/mo');
        if (house.numberOfRooms != null) subtitleParts.add('${house.numberOfRooms} rooms');
        final subtitle = subtitleParts.isEmpty ? null : subtitleParts.join(' • ');

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: ListTile(
            title: Text(
              house.address ?? 'Property',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            subtitle: subtitle == null
                ? null
                : Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70),
                  ),
            trailing: IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline, color: Colors.white70),
              onPressed: () => onDelete(house),
            ),
            onTap: () => onOpen(house),
          ),
        );
      },
    );
  }
}

class _MatchesGrid extends StatelessWidget {
  final List<ProfileModel> profiles;

  const _MatchesGrid({required this.profiles});

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text("No profiles yet.", style: TextStyle(color: Colors.white54))),
      );
    }

    // Increased crossAxisCount to make tiles smaller (downscaled)
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 5 : 3;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: profiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, i) => _GridTile(profile: profiles[i]),
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({required this.profile});
  final ProfileModel profile;

  void _showProfileModal(BuildContext context) {
    // Helper to compute budget level
    double computeBudgetLevel(int? min, int? max) {
      if (min == null && max == null) return 3;
      final values = [
        if (min != null) min.toDouble(),
        if (max != null) max.toDouble(),
      ];
      final v = values.isEmpty ? 0 : (values.reduce((a, b) => a + b) / values.length);
      if (v <= 100) return 1;
      if (v <= 300) return 2;
      if (v <= 500) return 3;
      if (v <= 1000) return 4;
      return 5;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Match theme
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Use DraggableScrollableSheet for flexible height
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Handle at top
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Avatar + Bio
                  Center(
                    child: ProfileAvatarSection(
                      imageUrl: profile.avatarUrl ?? "",
                      name: profile.fullName ?? 'User',
                      bio: profile.bio ?? 'No bio.',
                      onEditAvatar: null, // Read-only: hide edit icon
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // About Section
                  AboutSection(
                    occupation: profile.occupation,
                  ),
                  const SizedBox(height: 24),
                  
                  // Interests Section
                  InterestsSection(
                    interests: profile.interests ?? [],
                    onChanged: (_) {}, // Read-only no-op
                    isReadOnly: true,  // Hide add button and remove icons
                  ),
                  const SizedBox(height: 24),
                  
                  // Preferences Section
                  PreferencesSection(
                    budgetLevel: computeBudgetLevel(profile.budgetMin, profile.budgetMax),
                    cleanlinessLevel: (profile.cleanlinessLevel ?? 3).toDouble(),
                    noiseLevel: (profile.noiseLevel ?? 3).toDouble(),
                    smoking: profile.smokingPreference ?? false,
                    pets: profile.petsPreference ?? false,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final age = profile.dateOfBirth != null 
        ? (DateTime.now().difference(profile.dateOfBirth!).inDays / 365).floor() 
        : null;
    final label = '${profile.fullName?.split(' ').first ?? 'User'}${age != null ? ', $age' : ''}';
    
    return GestureDetector(
      onTap: () => _showProfileModal(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                      ? Image.network(profile.avatarUrl!, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.person, color: Colors.white, size: 48),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
