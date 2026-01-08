import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/house_model.dart';

class HouseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucket = 'HousePhotos';

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

    try {
      return House.fromJson(response.first as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Skipping invalid house row for host $hostId: $e');
      return null;
    }
  }

  /// Fetch all houses from the database.
  Future<List<House>> getAllHouses() async {
    final List<dynamic> response = await _supabase
        .from('houses')
        .select();

    final houses = <House>[];
    for (final row in response) {
      try {
        houses.add(House.fromJson(row as Map<String, dynamic>));
      } catch (e) {
        debugPrint('Skipping invalid house row: $e');
      }
    }
    return houses;
  }

  /// Fetch all houses listed by a specific user.
  Future<List<House>> getHousesForUser(String userId) async {
    final List<dynamic> response = await _supabase
        .from('houses')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final houses = <House>[];
    for (final row in response) {
      try {
        houses.add(House.fromJson(row as Map<String, dynamic>));
      } catch (e) {
        debugPrint('Skipping invalid house row for user $userId: $e');
      }
    }
    return houses;
  }

  /// Delete a house that belongs to the given user.
  Future<void> deleteHouse({required String houseId, required String userId}) async {
    await _supabase
        .from('houses')
        .delete()
        .eq('id', houseId)
        .eq('user_id', userId);
  }

  Future<String> uploadHousePhoto({required String userId, required XFile file}) async {
    final bytes = await file.readAsBytes();
    final ext = (file.name.contains('.')) ? file.name.split('.').last : 'jpg';
    final filePath = '$userId/house_${DateTime.now().millisecondsSinceEpoch}_${file.hashCode}.$ext';

    await _supabase.storage.from(_bucket).uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from(_bucket).getPublicUrl(filePath);
  }

  Future<void> updateHousePhotoUrls({
    required String houseId,
    required String userId,
    required List<String> urls,
  }) async {
    await _supabase
        .from('houses')
        .update({'image': urls})
        .eq('id', houseId)
        .eq('user_id', userId);
  }
}
