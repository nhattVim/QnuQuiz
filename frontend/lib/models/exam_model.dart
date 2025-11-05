class ExamModel {
  final int id;
  final String title;
  final String description;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool random;
  final int? durationMinutes;
  final String status;

  ExamModel({
    required this.id,
    required this.title,
    required this.description,
    this.startTime,
    this.endTime,
    required this.random,
    this.durationMinutes,
    required this.status,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      random: json['random'] as bool,
      durationMinutes: json['durationMinutes'] != null
          ? json['durationMinutes'] as int
          : null,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'random': random,
      'durationMinutes': durationMinutes,
      'status': status,
    };
  }
}
