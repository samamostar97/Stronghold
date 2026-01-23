class SeminarDTO {
  final int id;
  final String topic;
  final String speakerName;
  final DateTime eventDate;

  const SeminarDTO({
    required this.id,
    required this.topic,
    required this.speakerName,
    required this.eventDate,
  });

  factory SeminarDTO.fromJson(Map<String, dynamic> json) {
    return SeminarDTO(
      id: (json['id'] ?? 0) as int,
      topic: (json['topic'] ?? '') as String,
      speakerName: (json['speakerName'] ?? '') as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
    );
  }
}

class CreateSeminarDTO {
  final String topic;
  final String speakerName;
  final DateTime eventDate;

  const CreateSeminarDTO({
    required this.topic,
    required this.speakerName,
    required this.eventDate,
  });

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'speakerName': speakerName,
        'eventDate': eventDate.toIso8601String(),
      };
}

class UpdateSeminarDTO {
  final String? topic;
  final String? speakerName;
  final DateTime? eventDate;

  const UpdateSeminarDTO({
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

class PagedSeminarsResult {
  final List<SeminarDTO> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedSeminarsResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedSeminarsResult.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => SeminarDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <SeminarDTO>[];

    return PagedSeminarsResult(
      items: itemsList,
      totalCount: (json['totalCount'] ?? 0) as int,
      pageNumber: (json['pageNumber'] ?? 1) as int,
      pageSize: (json['pageSize'] ?? 10) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
    );
  }
}
