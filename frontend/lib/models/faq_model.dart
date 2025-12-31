class FaqDto {
  final int id;
  final String question;
  final String answer;

  FaqDto({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FaqDto.fromJson(Map<String, dynamic> json) {
    return FaqDto(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
    );
  }
}