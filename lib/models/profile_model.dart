// lib/models/profile_model.dart
import 'package:flutter/foundation.dart';

@immutable
class ProfileModel {
  // IDs & basics
  final String id; // uuid
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;

  // Personal
  final DateTime? dateOfBirth; // date
  final String? gender;        // text
  final String? bio;
  final String? occupation;
  final String? university;

  // Intent
  final bool? isLookingForRoommate;
  final bool? isLookingForPlace;

  // Budget
  final int? budgetMin; // int4
  final int? budgetMax; // int4

  // Location & timing
  final String? preferredLocation;
  final DateTime? moveInDate; // date

  // Preferences
  final bool? smokingPreference;   // boolean
  final bool? petsPreference;      // boolean
  final int? cleanlinessLevel;     // 1..5
  final int? noiseLevel;           // 1..5

  // Flags
  final bool? emailVerified;
  final bool? isActive;

  // Timestamps
  final DateTime? createdAt;   // timestamptz
  final DateTime? updatedAt;   // timestamptz

  const ProfileModel({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.bio,
    this.occupation,
    this.university,
    this.isLookingForRoommate,
    this.isLookingForPlace,
    this.budgetMin,
    this.budgetMax,
    this.preferredLocation,
    this.moveInDate,
    this.smokingPreference,
    this.petsPreference,
    this.cleanlinessLevel,
    this.noiseLevel,
    this.emailVerified,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  // ---------- Parsing helpers ----------
  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    // Supabase/date columns can come as 'YYYY-MM-DD' or ISO string
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  static bool? _parseBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    if (s == 'true' || s == 't' || s == '1') return true;
    if (s == 'false' || s == 'f' || s == '0') return false;
    return null;
    }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  // ---------- Factory: from DB map ----------
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String, // uuid required
      email: map['email'] as String?,
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      phone: map['phone'] as String?,
      dateOfBirth: _parseDate(map['date_of_birth']),
      gender: map['gender'] as String?,
      bio: map['bio'] as String?,
      occupation: map['occupation'] as String?,
      university: map['university'] as String?,
      isLookingForRoommate: _parseBool(map['is_looking_for_roommate']),
      isLookingForPlace: _parseBool(map['is_looking_for_place']),
      budgetMin: _parseInt(map['budget_min']),
      budgetMax: _parseInt(map['budget_max']),
      preferredLocation: map['preferred_location'] as String?,
      moveInDate: _parseDate(map['move_in_date']),
      smokingPreference: _parseBool(map['smoking_preference']),
      petsPreference: _parseBool(map['pets_preference']),
      cleanlinessLevel: _parseInt(map['cleanliness_level']),
      noiseLevel: _parseInt(map['noise_level']),
      emailVerified: _parseBool(map['email_verified']),
      isActive: _parseBool(map['is_active']),
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  // ---------- To DB/JSON map ----------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bio': bio,
      'occupation': occupation,
      'university': university,
      'is_looking_for_roommate': isLookingForRoommate,
      'is_looking_for_place': isLookingForPlace,
      'budget_min': budgetMin,
      'budget_max': budgetMax,
      'preferred_location': preferredLocation,
      'move_in_date': moveInDate?.toIso8601String(),
      'smoking_preference': smokingPreference,
      'pets_preference': petsPreference,
      'cleanliness_level': cleanlinessLevel,
      'noise_level': noiseLevel,
      'email_verified': emailVerified,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    }..removeWhere((_, v) => v == null);
  }

  // ---------- CopyWith ----------
  ProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? bio,
    String? occupation,
    String? university,
    bool? isLookingForRoommate,
    bool? isLookingForPlace,
    int? budgetMin,
    int? budgetMax,
    String? preferredLocation,
    DateTime? moveInDate,
    bool? smokingPreference,
    bool? petsPreference,
    String? guestsPreference,
    int? cleanlinessLevel,
    int? noiseLevel,
    bool? emailVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      occupation: occupation ?? this.occupation,
      university: university ?? this.university,
      isLookingForRoommate:
          isLookingForRoommate ?? this.isLookingForRoommate,
      isLookingForPlace: isLookingForPlace ?? this.isLookingForPlace,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      moveInDate: moveInDate ?? this.moveInDate,
      smokingPreference: smokingPreference ?? this.smokingPreference,
      petsPreference: petsPreference ?? this.petsPreference,
      cleanlinessLevel: cleanlinessLevel ?? this.cleanlinessLevel,
      noiseLevel: noiseLevel ?? this.noiseLevel,
      emailVerified: emailVerified ?? this.emailVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ---------- Convenience getters ----------
  /// If you store '1'..'5' for levels, this gives you an int safely.
  int? get cleanlinessLevelInt => cleanlinessLevel;
  int? get noiseLevelInt => noiseLevel;

  /// Human label for budget (optional helper)
  String get budgetLabel {
    final min = budgetMin ?? 0;
    final max = budgetMax ?? 0;
    if (max > 0 && min > 0) return '\$$min–\$$max';
    if (max > 0 && min == 0 && max < 500) return 'Under \$500';
    if (min >= 1500 && max == 0) return 'Over \$1500';
    if (min > 0 && max == 0) return '\$$min+';
    if (max > 0 && min == 0) return 'Up to \$$max';
    return 'Not set';
  }
}
