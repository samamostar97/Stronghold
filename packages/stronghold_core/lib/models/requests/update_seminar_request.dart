/// Matches backend UpdateSeminarRequest exactly
class UpdateSeminarRequest {
  final String? topic;
  final String? speakerName;
  final DateTime? eventDate;

  const UpdateSeminarRequest({
    this.topic,
    this.speakerName,
    this.eventDate,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (topic != null) map['topic'] = topic;
    if (speakerName != null) map['speakerName'] = speakerName;
    if (eventDate != null) map['eventDate'] = eventDate!.toIso8601String();
    return map;
  }
}
