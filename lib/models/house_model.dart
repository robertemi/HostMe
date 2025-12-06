import 'package:meta/meta.dart';

class House {
  final String id;
  final String userId;

  final DateTime createdAt;

  final String? address;
  final int? numberOfRooms;
  final int? numberOfBalconies;
  final int? numberOfBedrooms;
  final int? numberOfBathrooms;

  final double? rent;
  final double? livingArea;

  final int? floorNumber;
  final String? type;

  final bool? hasElevator;
  final bool? hasPersonalHeating;

  final int? numberOfCurrentRoommates;

  /// Legacy single image field in DB
  final String? image;

  /// New field for up to 5 images (your app requirement)
  final List<String>? imagePaths;

  House({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.address,
    this.numberOfRooms,
    this.numberOfBalconies,
    this.numberOfBedrooms,
    this.numberOfBathrooms,
    this.rent,
    this.livingArea,
    this.floorNumber,
    this.type,
    this.hasElevator,
    this.hasPersonalHeating,
    this.numberOfCurrentRoommates,
    this.image,
    this.imagePaths,
  });

  // -----------------------------
  // FROM JSON
  // -----------------------------
  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at']),

      address: json['address'] as String?,
      numberOfRooms: json['number_of_rooms'] as int?,
      numberOfBalconies: json['number_of_balconies'] as int?,
      numberOfBedrooms: json['number_of_bedrooms'] as int?,
      numberOfBathrooms: json['number_of_bathrooms'] as int?,

      rent: (json['rent'] as num?)?.toDouble(),
      livingArea: (json['living_area'] as num?)?.toDouble(),

      floorNumber: json['floor_number'] as int?,
      type: json['type'] as String?,

      hasElevator: json['has_elevator'] as bool?,
      hasPersonalHeating: json['has_personal_heating'] as bool?,

      numberOfCurrentRoommates: json['number_of_current_roommates'] as int?,

      image: json['image'] as String?,

      // Convert comma-separated or JSON array to List<String>
      imagePaths: _parseImagePaths(json['image_path']),
    );
  }

  // -----------------------------
  // TO JSON
  // -----------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),

      'address': address,
      'number_of_rooms': numberOfRooms,
      'number_of_balconies': numberOfBalconies,
      'number_of_bedrooms': numberOfBedrooms,
      'number_of_bathrooms': numberOfBathrooms,

      'rent': rent,
      'living_area': livingArea,

      'floor_number': floorNumber,
      'type': type,

      'has_elevator': hasElevator,
      'has_personal_heating': hasPersonalHeating,

      'number_of_current_roommates': numberOfCurrentRoommates,

      'image': image,

      'image_path': imagePaths,
    };
  }

  // -----------------------------
  // Helper to parse image paths
  // -----------------------------
  static List<String>? _parseImagePaths(dynamic raw) {
    if (raw == null) return null;

    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }

    // If database stores them as a comma-separated String
    if (raw is String) {
      return raw.split(',').map((e) => e.trim()).toList();
    }

    return null;
  }
}
