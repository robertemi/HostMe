import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../widgets/matches_screen_widgets/match_tile.dart';
// bottom nav is provided by RootShell
import 'chat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;


String formatTimeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);

  if (diff.inSeconds < 60) return "just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
  if (diff.inHours < 24) return "${diff.inHours}h ago";
  return "${diff.inDays}d ago";
}


DateTime _parseTime(dynamic createdAt) {
  if (createdAt is String) {
    return DateTime.tryParse(createdAt) ?? DateTime.now();
  } else if (createdAt is DateTime) {
    return createdAt;
  } else {
    return DateTime.now();
  }
}


Future<List<MatchModel>> fetchMatches() async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  // Get matches where current user is either user1 or user2
  final response = await supabase
      .from('matches')
      .select('id, user1_id, user2_id, created_at, user1:profiles!user1_id(*), user2:profiles!user2_id(*)')
      .or('user1_id.eq.$userId,user2_id.eq.$userId');

  if (response.isEmpty) return [];

  return response.map<MatchModel>((match) {
    final isUser1 = match['user1_id'] == userId;
    final otherUser = isUser1 ? match['user2'] : match['user1'];

    return MatchModel(
      id: otherUser['id'],
      name: otherUser['full_name'] ?? 'Unknown',
      avatarUrl: otherUser['avatar_url'] ?? 'null',
      message: '', // can fill from latest chat message later
      timeAgo: formatTimeAgo(_parseTime(match['created_at'])),
      isOnline: otherUser['is_online'] ?? false,
    );
  }).toList();
}


class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  late Future<List<MatchModel>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = fetchMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<MatchModel>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final matches = snapshot.data ?? [];
          if (matches.isEmpty) return _buildEmptyState(context);

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        receiverId: match.id,
                        receiverName: match.name,
                        receiverAvatar: match.avatarUrl,
                      ),
                    ),
                  );
                },
                child: MatchTile(match: match),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_add_alt_1_outlined,
              size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'No matches yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep exploring to find your perfect roommate!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}