/// Matches backend UpdateFaqRequest exactly
class UpdateFaqRequest {
  final String? question;
  final String? answer;

  const UpdateFaqRequest({
    this.question,
    this.answer,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (question != null) map['question'] = question;
    if (answer != null) map['answer'] = answer;
    return map;
  }
}
