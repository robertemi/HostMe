import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../widgets/matches_screen_widgets/match_tile.dart';
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

  final response = await supabase
      .from('matches')
      .select(
          'id, user1_id, user2_id, created_at, user1:profiles!user1_id(*), user2:profiles!user2_id(*)')
      .or('user1_id.eq.$userId,user2_id.eq.$userId');

  if (response.isEmpty) return [];

  return response.map<MatchModel>((match) {
    final isUser1 = match['user1_id'] == userId;
    final otherUser = isUser1 ? match['user2'] : match['user1'];

    return MatchModel(
      id: otherUser['id'],
      name: otherUser['full_name'] ?? 'Unknown',
      avatarUrl: otherUser['avatar_url'] ?? 'null',
      message: '',
      timeAgo: formatTimeAgo(_parseTime(match['created_at'])),
      isOnline: otherUser['is_online'] ?? false,
    );
  }).toList();
}

Future<void> deleteMatch(String otherUserId) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return;

  await supabase.from('matches').delete().or(
        'and(user1_id.eq.$userId,user2_id.eq.$otherUserId),'
        'and(user1_id.eq.$otherUserId,user2_id.eq.$userId)',
      );
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
        title: const Text(
          'Matches',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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

          if (matches.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];

              return Dismissible(
                key: ValueKey(match.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Remove match?'),
                      content: const Text(
                        'This will permanently remove the match and chat.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) async {
                  await deleteMatch(match.id);
                  setState(() {
                    _matchesFuture = fetchMatches();
                  });
                },
                child: GestureDetector(
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
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add_alt_1_outlined,
              size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'No matches yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Keep exploring to find your perfect roommate!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
