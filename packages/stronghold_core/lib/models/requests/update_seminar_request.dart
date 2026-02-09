/// Matches backend UpdateSeminarRequest exactly
class UpdateSeminarRequest {
  final String? topic;
  final String? speakerName;
  final DateTime? eventDate;
  final int? maxCapacity;

  const UpdateSeminarRequest({
    this.topic,
    this.speakerName,
    this.eventDate,
    this.maxCapacity,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (topic != null) map['topic'] = topic;
    if (speakerName != null) map['speakerName'] = speakerName;
    if (eventDate != null) map['eventDate'] = eventDate!.toIso8601String();
    if (maxCapacity != null) map['maxCapacity'] = maxCapacity;
    return map;
  }
}
