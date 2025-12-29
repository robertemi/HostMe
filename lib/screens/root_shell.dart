import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/common/app_bottom_nav_bar.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';

class RootShell extends StatefulWidget {
  /// [initialIndex] controls which tab is shown when the shell is first displayed.
  /// Defaults to 0 (Home).
  const RootShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late final PageController _pageController;
  late int _currentIndex;
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Request notification permissions on startup
    NotificationService().requestPermissions();
    
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    print('DEBUG: Setting up realtime listeners for user $userId');

    // Listen for new messages
    _supabase
        .channel('global_messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) {
            print('DEBUG: Received new message payload: ${payload.newRecord}');
            final msg = payload.newRecord;
            // Don't show notification if we are on the matches screen (index 1)
            // Ideally we check if we are in the specific chat, but this is a simple check
            if (_currentIndex != 1) {
              print('DEBUG: Showing notification for message');
              NotificationService().showNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                title: 'New Message',
                body: msg['text'] ?? 'You have a new message',
                payload: 'chat',
              );
            } else {
              print('DEBUG: Suppressing notification because user is on chat tab');
            }
          },
        )
        .subscribe((status, error) {
           print('DEBUG: Messages channel status: $status, error: $error');
        });

    // Listen for new matches (assuming a 'matches' table exists)
    // We need to listen for inserts where user1_id = me OR user2_id = me
    // Supabase realtime filters are simple equality. We might need two channels or just listen to all and filter client side if RLS allows.
    // Assuming RLS restricts us to only see our own matches, we can listen to all inserts on 'matches'.
    _supabase
        .channel('global_matches')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'matches',
          callback: (payload) {
            final match = payload.newRecord;
            final u1 = match['user1_id'];
            final u2 = match['user2_id'];
            if (u1 == userId || u2 == userId) {
                NotificationService().showNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                title: "It's a Match!",
                body: "You have a new match! Check it out.",
                payload: 'match',
              );
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int idx) {
    setState(() => _currentIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        // allow natural swiping between pages; use default physics to respect platform behavior
        allowImplicitScrolling: true,
        children: const [
          HomeScreen(),
          MatchesScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => _pageController.jumpToPage(i),
        pageController: _pageController,
      ),
    );
  }
}
