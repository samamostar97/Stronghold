class FaqItem {
  final int id;
  final String question;
  final String answer;

  FaqItem({required this.id, required this.question, required this.answer});

  factory FaqItem.fromJson(Map<String, dynamic> json) => FaqItem(
        id: json['id'] as int,
        question: json['question'] as String,
        answer: json['answer'] as String,
      );
}
