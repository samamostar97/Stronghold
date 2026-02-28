class StaffReportDTO {
  final int totalAppointments;
  final int trainerAppointments;
  final int nutritionistAppointments;
  final int totalTrainers;
  final int totalNutritionists;
  final List<StaffRankingItemDTO> staffRanking;

  StaffReportDTO({
    required this.totalAppointments,
    required this.trainerAppointments,
    required this.nutritionistAppointments,
    required this.totalTrainers,
    required this.totalNutritionists,
    required this.staffRanking,
  });

  factory StaffReportDTO.fromJson(Map<String, dynamic> json) {
    return StaffReportDTO(
      totalAppointments: (json['totalAppointments'] ?? 0) as int,
      trainerAppointments: (json['trainerAppointments'] ?? 0) as int,
      nutritionistAppointments: (json['nutritionistAppointments'] ?? 0) as int,
      totalTrainers: (json['totalTrainers'] ?? 0) as int,
      totalNutritionists: (json['totalNutritionists'] ?? 0) as int,
      staffRanking: (json['staffRanking'] as List<dynamic>?)
              ?.map((e) => StaffRankingItemDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <StaffRankingItemDTO>[],
    );
  }
}

class StaffRankingItemDTO {
  final String name;
  final int appointmentCount;
  final String type;

  StaffRankingItemDTO({
    required this.name,
    required this.appointmentCount,
    required this.type,
  });

  factory StaffRankingItemDTO.fromJson(Map<String, dynamic> json) {
    return StaffRankingItemDTO(
      name: (json['name'] ?? '') as String,
      appointmentCount: (json['appointmentCount'] ?? 0) as int,
      type: (json['type'] ?? '') as String,
    );
  }
}

