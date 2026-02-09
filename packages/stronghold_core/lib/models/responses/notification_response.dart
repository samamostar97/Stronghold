/// Matches backend NotificationResponse
class NotificationDTO {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final int? relatedEntityId;
  final String? relatedEntityType;

  const NotificationDTO({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.relatedEntityId,
    this.relatedEntityType,
  });

  factory NotificationDTO.fromJson(Map<String, dynamic> json) {
    return NotificationDTO(
      id: (json['id'] ?? 0) as int,
      type: (json['type'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      message: (json['message'] ?? '') as String,
      isRead: (json['isRead'] ?? false) as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      relatedEntityId: json['relatedEntityId'] as int?,
      relatedEntityType: json['relatedEntityType'] as String?,
    );
  }

  NotificationDTO copyWith({bool? isRead}) {
    return NotificationDTO(
      id: id,
      type: type,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
    );
  }
}
