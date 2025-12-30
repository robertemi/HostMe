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
}
