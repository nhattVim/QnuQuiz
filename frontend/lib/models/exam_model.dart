class ExamModel {
  final int id;
  final String title;
  final String description;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool random;
  final int? durationMinutes;
  final String status;
  final bool hasUnfinishedAttempt;

  ExamModel({
    required this.id,
    required this.title,
    required this.description,
    this.startTime,
    this.endTime,
    required this.random,
    this.durationMinutes,
    required this.status,
    this.hasUnfinishedAttempt = false,
  });

  String get computedStatus {
    final now = DateTime.now();

    if (startTime == null || endTime == null) {
      return "closed";
    }

    if (now.isBefore(startTime!)) {
      return "unopened";
    }

    if (now.isAfter(startTime!) && now.isBefore(endTime!)) {
      return "active";
    }

    return "closed";
  }

  bool get isOpen => computedStatus == "active";

  bool get isUnopened => computedStatus == "unopened";

  bool get isClosed => computedStatus == "closed";

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as int,
      title: json['title'],
      description: json['description'],
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      random: json['random'] as bool,
      durationMinutes: json['durationMinutes'],
      status: json['status'],
      hasUnfinishedAttempt: json['hasUnfinishedAttempt'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'random': random,
      'durationMinutes': durationMinutes,
      'status': status,
      'hasUnfinishedAttempt': hasUnfinishedAttempt,
    };
  }
}
