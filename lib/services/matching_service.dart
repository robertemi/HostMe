import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match_result.dart';

class MatchingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Calls the 'get_smart_matches' RPC function in Supabase.
  /// Returns a list of compatible users/houses sorted by match score.
  Future<List<MatchResult>> getSmartMatches() async {
    try {
      final List<dynamic> response = await _supabase.rpc('get_smart_matches');
      
      // Map the raw JSON response to our model
      final matches = response
          .map((json) => MatchResult.fromMap(json as Map<String, dynamic>))
          .toList();
          
      // Sort by highest match score first
      matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      
      return matches;
    } catch (e) {
      // In a real app, you might log this error
      throw Exception('Failed to load matches: $e');
    }
  }

  /// Records a swipe action (Like or Nope).
  /// Returns true if it resulted in a Match (Mutual Like).
  Future<bool> swipeUser(String targetUserId, bool isLike) async {
    try {
      final bool isMatch = await _supabase.rpc('handle_swipe', params: {
        'target_user_id': targetUserId,
        'liked': isLike,
      });
      return isMatch;
    } catch (e) {
      throw Exception('Failed to record swipe: $e');
    }
  }
}
