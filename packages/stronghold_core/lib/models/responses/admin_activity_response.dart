import '../common/date_time_utils.dart';

class AdminActivityResponse {
  final int id;
  final String actionType;
  final String entityType;
  final int entityId;
  final String description;
  final String adminUsername;
  final DateTime createdAt;
  final DateTime undoAvailableUntil;
  final bool isUndone;
  final bool canUndo;

  const AdminActivityResponse({
    required this.id,
    required this.actionType,
    required this.entityType,
    required this.entityId,
    required this.description,
    required this.adminUsername,
    required this.createdAt,
    required this.undoAvailableUntil,
    required this.isUndone,
    required this.canUndo,
  });

  factory AdminActivityResponse.fromJson(Map<String, dynamic> json) {
    return AdminActivityResponse(
      id: (json['id'] ?? 0) as int,
      actionType: (json['actionType'] ?? '') as String,
      entityType: (json['entityType'] ?? '') as String,
      entityId: (json['entityId'] ?? 0) as int,
      description: (json['description'] ?? '') as String,
      adminUsername: (json['adminUsername'] ?? '') as String,
      createdAt: json['createdAt'] != null
          ? DateTimeUtils.parseApiDateTime(json['createdAt'] as String)
          : DateTime.now(),
      undoAvailableUntil: json['undoAvailableUntil'] != null
          ? DateTimeUtils.parseApiDateTime(json['undoAvailableUntil'] as String)
          : DateTime.now(),
      isUndone: (json['isUndone'] ?? false) as bool,
      canUndo: (json['canUndo'] ?? false) as bool,
    );
  }

  AdminActivityResponse copyWith({bool? isUndone, bool? canUndo}) {
    return AdminActivityResponse(
      id: id,
      actionType: actionType,
      entityType: entityType,
      entityId: entityId,
      description: description,
      adminUsername: adminUsername,
      createdAt: createdAt,
      undoAvailableUntil: undoAvailableUntil,
      isUndone: isUndone ?? this.isUndone,
      canUndo: canUndo ?? this.canUndo,
    );
  }
}
