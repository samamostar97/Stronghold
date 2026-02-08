/// Matches backend CreateFaqRequest exactly
class CreateFaqRequest {
  final String question;
  final String answer;

  const CreateFaqRequest({
    required this.question,
    required this.answer,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };
}
