/// Matches backend CreateMembershipPackageRequest exactly
class CreateMembershipPackageRequest {
  final String packageName;
  final double packagePrice;
  final String? description;
  final bool isActive;

  const CreateMembershipPackageRequest({
    required this.packageName,
    required this.packagePrice,
    this.description,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'packagePrice': packagePrice,
        if (description != null) 'description': description,
        'isActive': isActive,
      };
}
