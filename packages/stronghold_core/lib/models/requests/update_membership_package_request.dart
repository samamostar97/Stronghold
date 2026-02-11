/// Matches backend UpdateMembershipPackageRequest exactly
class UpdateMembershipPackageRequest {
  final String? packageName;
  final double? packagePrice;
  final String? description;

  const UpdateMembershipPackageRequest({
    this.packageName,
    this.packagePrice,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (packageName != null) map['packageName'] = packageName;
    if (packagePrice != null) map['packagePrice'] = packagePrice;
    if (description != null) map['description'] = description;
    return map;
  }
}
