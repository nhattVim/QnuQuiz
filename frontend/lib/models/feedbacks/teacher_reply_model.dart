class TeacherReplyModel {
  final String reply;
  final String? status;

  TeacherReplyModel({required this.reply, this.status});

  Map<String, dynamic> toJson() => {
    'reply': reply,
    if (status != null) 'status': status,
  };
}
