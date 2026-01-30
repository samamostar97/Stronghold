class Faq {
  final int id;
  final String question;
  final String answer;

  Faq({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }
}
