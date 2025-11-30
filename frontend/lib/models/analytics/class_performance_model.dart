class ClassPerformance {
  final String className;
  final int studentCount;
  final double avgScorePerClass;

  ClassPerformance({
    required this.className,
    required this.studentCount,
    required this.avgScorePerClass,
  });

  factory ClassPerformance.fromJson(Map<String, dynamic> json) {
    return ClassPerformance(
      className: json['className'],
      studentCount: json['studentCount'],
      avgScorePerClass: (json['avgScorePerClass'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
