class UpdateFeedbackModel {
  final String? content;
  final int? rating;
  final String? status;

  UpdateFeedbackModel({this.content, this.rating, this.status});

  Map<String, dynamic> toJson() => {
    if (content != null) 'content': content,
    if (rating != null) 'rating': rating,
    if (status != null) 'status': status,
  };
}
