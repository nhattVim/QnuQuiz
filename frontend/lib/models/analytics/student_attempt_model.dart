class StudentAttempt {
  final String studentCode;
  final String fullName;
  final String className;
  final DateTime startTime;
  final DateTime endTime;
  final double durationMinutes;
  final double score;
  final bool submitted;

  StudentAttempt({
    required this.studentCode,
    required this.fullName,
    required this.className,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.score,
    required this.submitted,
  });

  factory StudentAttempt.fromJson(Map<String, dynamic> json) {
    return StudentAttempt(
      studentCode: json['studentCode'],
      fullName: json['fullName'],
      className: json['className'],
      startTime: json['startTime'] == null ? DateTime.now() : DateTime.parse(json['startTime']),
      endTime: json['endTime'] == null ? DateTime.now() : DateTime.parse(json['endTime']),
      durationMinutes: (json['durationMinutes'] as num?)?.toDouble() ?? 0.0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      submitted: json['submitted'],
    );
  }
}
