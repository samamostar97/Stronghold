/// Matches backend UpdateFaqRequest exactly
class UpdateFaqRequest {
  final String question;
  final String answer;

  const UpdateFaqRequest({
    required this.question,
    required this.answer,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };
}
