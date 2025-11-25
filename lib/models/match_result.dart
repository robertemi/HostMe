class MatchResult {
  final String userId;
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
  
  // House Data (nullable, only for Hosts)
  final String? houseId;
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
    this.houseId,
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
      houseId: map['house_id'] as String?,
      houseAddress: map['house_address'] as String?,
      houseRent: (map['house_rent'] as num?)?.toDouble(),
      houseImage: map['house_image'] as String?,
    );
  }
}
