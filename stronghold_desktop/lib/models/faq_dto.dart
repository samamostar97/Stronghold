class FaqDTO {
  final int id;
  final String question;
  final String answer;



  const FaqDTO({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FaqDTO.fromJson(Map<String, dynamic> json) {
    return FaqDTO(
      id: (json['id'] ?? 0) as int,
      question: (json['question'] ?? '') as String,
      answer: (json['answer'] ?? '') as String,
    );
  }
}

class CreateFaqDTO {
  final String question;
  final String answer;


  const CreateFaqDTO({
    required this.question,
    required this.answer,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };
}

class UpdateFaqDTO {
  final String? question;
  final String? answer;

  const UpdateFaqDTO({
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

class PagedFaqsResult {
  final List<FaqDTO> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedFaqsResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedFaqsResult.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => FaqDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <FaqDTO>[];

    return PagedFaqsResult(
      items: itemsList,
      totalCount: (json['totalCount'] ?? 0) as int,
      pageNumber: (json['pageNumber'] ?? 1) as int,
      pageSize: (json['pageSize'] ?? 10) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
    );
  }
}
