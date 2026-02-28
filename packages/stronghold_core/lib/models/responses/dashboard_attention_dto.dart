class DashboardAttentionDTO {
  final int pendingOrdersCount;
  final int expiringMembershipsCount;
  final int windowDays;

  DashboardAttentionDTO({
    required this.pendingOrdersCount,
    required this.expiringMembershipsCount,
    required this.windowDays,
  });

  factory DashboardAttentionDTO.fromJson(Map<String, dynamic> json) {
    return DashboardAttentionDTO(
      pendingOrdersCount: (json['pendingOrdersCount'] ?? 0) as int,
      expiringMembershipsCount: (json['expiringMembershipsCount'] ?? 0) as int,
      windowDays: (json['windowDays'] ?? 7) as int,
    );
  }
}
