class MatchResult {
  final String userId;          // the "other" user's id (the one you see on the card)
  final String? fullName;
  final String? avatarUrl;
  final int? age;
  final String? gender;
  final String? bio;
  final String? occupation;

  // Scores
  final int matchScore;
  final int budgetScore;
  final int lifestyleScore;

  // Optional house data if you join it in the query
  final String? houseAddress;
  final double? houseRent;
  final String? houseImage;

  MatchResult({
    required this.userId,
    this.fullName,
    this.avatarUrl,
    this.age,
    this.gender,
    this.bio,
    this.occupation,
    required this.matchScore,
    required this.budgetScore,
    required this.lifestyleScore,
    this.houseAddress,
    this.houseRent,
    this.houseImage,
  });

  factory MatchResult.fromMap(Map<String, dynamic> map) {
    return MatchResult(
      userId: map['user_id'] as String,
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      bio: map['bio'] as String?,
      occupation: map['occupation'] as String?,
      matchScore: map['match_score'] as int? ?? 0,
      budgetScore: map['budget_score'] as int? ?? 0,
      lifestyleScore: map['lifestyle_score'] as int? ?? 0,
      houseAddress: map['house_address'] as String?,
      houseRent: (map['house_rent'] as num?)?.toDouble(),
      houseImage: _parseSingleImage(map['house_image']),
    );
  }

  static String? _parseSingleImage(dynamic raw) {
    if (raw == null) return null;
    String s = raw.toString();
    // If it looks like a JSON array ["url"], take the first one
    if (s.trim().startsWith('[') && s.trim().endsWith(']')) {
      try {
        final content = s.trim().substring(1, s.trim().length - 1);
        if (content.isEmpty) return null;
        final parts = content.split(',');
        if (parts.isNotEmpty) {
          return parts.first.trim().replaceAll('"', '').replaceAll("'", "");
        }
      } catch (_) {}
    }
    return s;
  }
}
