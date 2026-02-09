/// Matches backend CreateMembershipPackageRequest exactly
class CreateMembershipPackageRequest {
  final String packageName;
  final double packagePrice;
  final String? description;

  const CreateMembershipPackageRequest({
    required this.packageName,
    required this.packagePrice,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'packagePrice': packagePrice,
        if (description != null) 'description': description,
      };
}
