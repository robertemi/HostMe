import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ProfileModel?> fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select('*, profile_interests(interests(name))')
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromMap(data);
  }

  Future<bool> isProfileComplete(String userId) async {
    final profile = await fetchProfile(userId);
    return profile != null;
  }

  Future<void> upsertProfile(ProfileModel profile) async {
    // 1. Upsert profile data
    final response = await _client
        .from('profiles')
        .upsert(profile.toMap())
        .select(); // Returns List<Map<String, dynamic>>
    if (response.isEmpty) {
      throw Exception('Profile upsert failed: empty response list');
    }

    // 2. Handle interests if provided
    if (profile.interests != null) {
      final interests = profile.interests!.toSet().toList(); // Dedup

      if (interests.isNotEmpty) {
        // a. Ensure interests exist in 'interests' table and get their IDs
        final interestMaps = interests.map((e) => {'name': e}).toList();
        
        // Upsert interests to ensure they exist and get IDs
        final interestRows = await _client
            .from('interests')
            .upsert(interestMaps, onConflict: 'name')
            .select('id');
        
        final interestIds = (interestRows as List).map((e) => e['id'] as int).toList();

        // b. Update junction table
        // Delete existing links for this profile
        await _client
            .from('profile_interests')
            .delete()
            .eq('profile_id', profile.id);

        // Insert new links
        final junctionMaps = interestIds.map((id) => {
          'profile_id': profile.id,
          'interest_id': id,
        }).toList();

        if (junctionMaps.isNotEmpty) {
          await _client.from('profile_interests').insert(junctionMaps);
        }
      } else {
        // If list is empty, clear all interests
        await _client
            .from('profile_interests')
            .delete()
            .eq('profile_id', profile.id);
      }
    }
  }

  Future<List<ProfileModel>> getSwipedProfiles(String userId) async {
    try {
      final response = await _client
          .from('swipes')
          .select('profiles!swipes_target_id_fkey(*)')
          .eq('liker_id', userId)
          .eq('is_like', true)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data
          .map((e) => ProfileModel.fromMap(e['profiles'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ProfileModel>> getMatches(String userId) async {
    try {
      final response = await _client
          .from('matches')
          .select('''
            user1:profiles!matches_user1_id_fkey(*),
            user2:profiles!matches_user2_id_fkey(*)
          ''')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((e) {
        final user1 = e['user1'] as Map<String, dynamic>;
        final user2 = e['user2'] as Map<String, dynamic>;
        
        if (user1['id'] == userId) {
          return ProfileModel.fromMap(user2);
        } else {
          return ProfileModel.fromMap(user1);
        }
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
