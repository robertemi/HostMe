import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/profile_service.dart';
import '../../models/profile_model.dart';

class ActivitySection extends StatefulWidget {
  const ActivitySection({super.key});

  @override
  State<ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends State<ActivitySection> {
  List<ProfileModel> _matches = [];
  List<ProfileModel> _swipes = [];
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
      try {
        final matches = await service.getMatches(user.id);
        final swipes = await service.getSwipedProfiles(user.id);
        if (mounted) {
          setState(() {
            _matches = matches;
            _swipes = swipes;
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
        else
          _MatchesGrid(
            profiles: _tabIndex == 0 ? _matches : (_tabIndex == 1 ? _swipes : []),
            isLocked: _tabIndex == 2, // "Liked You" is locked/static for now
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
    final labels = ['Matches', 'Past Swipes', 'Liked You'];
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

class _MatchesGrid extends StatelessWidget {
  final List<ProfileModel> profiles;
  final bool isLocked;

  const _MatchesGrid({required this.profiles, this.isLocked = false});

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
       return Container(
         padding: const EdgeInsets.all(32),
         alignment: Alignment.center,
         child: Column(
           children: [
             const Icon(Icons.lock, color: Colors.white54, size: 48),
             const SizedBox(height: 16),
             const Text(
               "Upgrade to see who liked you!",
               style: TextStyle(color: Colors.white70, fontSize: 16),
               textAlign: TextAlign.center,
             ),
           ],
         ),
       );
    }
    
    if (profiles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text("No profiles yet.", style: TextStyle(color: Colors.white54))),
      );
    }

    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;
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
  
  @override
  Widget build(BuildContext context) {
    final age = profile.dateOfBirth != null 
        ? (DateTime.now().difference(profile.dateOfBirth!).inDays / 365).floor() 
        : null;
    final label = '${profile.fullName?.split(' ').first ?? 'User'}${age != null ? ', $age' : ''}';
    
    return Column(
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
    );
  }
}
