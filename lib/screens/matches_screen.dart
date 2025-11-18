import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../widgets/matches_screen_widgets/match_tile.dart';
// bottom nav is provided by RootShell
import 'chat_screen.dart'; // 👈 import your chat screen

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  // nav handled by RootShell

  @override
  Widget build(BuildContext context) {
    final matches = [
      MatchModel(
        id: 'uuid-olivia', // 👈 added id
        name: 'Olivia',
        message: 'Hey, how are you?',
        timeAgo: '2h ago',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        isOnline: true,
        unreadCount: 2,
      ),
      MatchModel(
        id: 'uuid-liam',
        name: 'Liam',
        message: 'Sounds good!',
        timeAgo: '4h ago',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        isOnline: true,
      ),
      MatchModel(
        id: 'uuid-sophia',
        name: 'Sophia',
        message: 'See you then!',
        timeAgo: '1d ago',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
      ),
      MatchModel(
        id: 'uuid-noah',
        name: 'Noah',
        message: "Let's do it.",
        timeAgo: '3d ago',
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: matches.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return GestureDetector(
                  onTap: () {
                    // 👇 Navigate to ChatScreen with match details
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
            ),
      // bottom nav provided by RootShell
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_add_alt_1_outlined, size: 64, color: Colors.blue),
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Find Roommates'),
          ),
        ],
      ),
    );
  }
}
