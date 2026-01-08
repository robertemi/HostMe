import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/house_model.dart';

class HouseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch the first house owned by this host (user_id in houses table).
  Future<House?> getHouseForHost(String hostId) async {
    final List<dynamic> response = await _supabase
        .from('houses')
        .select()
        .eq('user_id', hostId)
        .limit(1);

    if (response.isEmpty) {
      return null;
    }

    return House.fromJson(response.first as Map<String, dynamic>);
  }

  /// Fetch all houses from the database.
  Future<List<House>> getAllHouses() async {
    final List<dynamic> response = await _supabase
        .from('houses')
        .select();

    return response
        .map((json) => House.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch all houses listed by a specific user.
  Future<List<House>> getHousesForUser(String userId) async {
    final List<dynamic> response = await _supabase
        .from('houses')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response
        .map((json) => House.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Delete a house that belongs to the given user.
  Future<void> deleteHouse({required String houseId, required String userId}) async {
    await _supabase
        .from('houses')
        .delete()
        .eq('id', houseId)
        .eq('user_id', userId);
  }
}
