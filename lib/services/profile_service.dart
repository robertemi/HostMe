import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ProfileModel?> fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
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
    // Request returning the inserted/updated row to verify success.
    final response = await _client
        .from('profiles')
        .upsert(profile.toMap())
        .select(); // Returns List<Map<String, dynamic>>
    if (response.isEmpty) {
      throw Exception('Profile upsert failed: empty response list');
    }
  }
}
