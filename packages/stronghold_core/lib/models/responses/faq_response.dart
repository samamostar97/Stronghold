/// Matches backend FaqResponse
class FaqResponse {
  final int id;
  final String question;
  final String answer;

  const FaqResponse({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FaqResponse.fromJson(Map<String, dynamic> json) {
    return FaqResponse(
      id: (json['id'] ?? 0) as int,
      question: (json['question'] ?? '') as String,
      answer: (json['answer'] ?? '') as String,
    );
  }
}
