/// Matches backend MembershipPackageResponse exactly
class MembershipPackageResponse {
  final int id;
  final String? packageName;
  final double packagePrice;
  final String? description;

  const MembershipPackageResponse({
    required this.id,
    this.packageName,
    required this.packagePrice,
    this.description,
  });

  factory MembershipPackageResponse.fromJson(Map<String, dynamic> json) {
    return MembershipPackageResponse(
      id: (json['id'] ?? 0) as int,
      packageName: json['packageName'] as String?,
      packagePrice: ((json['packagePrice'] ?? 0) as num).toDouble(),
      description: json['description'] as String?,
    );
  }
}
