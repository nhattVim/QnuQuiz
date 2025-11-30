class ScoreDistribution {
  final String title;
  final int excellentCount;
  final int goodCount;
  final int averageCount;
  final int failCount;

  ScoreDistribution({
    required this.title,
    required this.excellentCount,
    required this.goodCount,
    required this.averageCount,
    required this.failCount,
  });

  factory ScoreDistribution.fromJson(Map<String, dynamic> json) {
    return ScoreDistribution(
      title: json['title'],
      excellentCount: json['excellentCount'],
      goodCount: json['goodCount'],
      averageCount: json['averageCount'],
      failCount: json['failCount'],
    );
  }
}
