/// Matches backend UpdateMembershipPackageRequest exactly
class UpdateMembershipPackageRequest {
  final String packageName;
  final double packagePrice;
  final String? description;

  const UpdateMembershipPackageRequest({
    required this.packageName,
    required this.packagePrice,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'packagePrice': packagePrice,
        'description': description,
      };
}
