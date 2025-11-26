class RankingModel {
  final String? username;
  final int? score;
  final String? fullName;
  final String? avatarUrl;

  RankingModel({
    required this.username,
    required this.score,
    required this.fullName,
    required this.avatarUrl,
  });

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      username: json['username'] as String?,
      score: (json['score'] as num?)?.toInt(),
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
