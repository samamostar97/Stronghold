/// Matches backend MembershipPackageResponse exactly
class MembershipPackageResponse {
  final int id;
  final String? packageName;
  final double packagePrice;
  final String? description;
  final bool isActive;

  const MembershipPackageResponse({
    required this.id,
    this.packageName,
    required this.packagePrice,
    this.description,
    required this.isActive,
  });

  factory MembershipPackageResponse.fromJson(Map<String, dynamic> json) {
    return MembershipPackageResponse(
      id: (json['id'] ?? 0) as int,
      packageName: json['packageName'] as String?,
      packagePrice: ((json['packagePrice'] ?? 0) as num).toDouble(),
      description: json['description'] as String?,
      isActive: (json['isActive'] ?? true) as bool,
    );
  }
}
