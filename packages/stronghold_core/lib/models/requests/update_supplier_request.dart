/// Matches backend UpdateSupplierRequest exactly
class UpdateSupplierRequest {
  final String name;
  final String? website;

  const UpdateSupplierRequest({
    required this.name,
    this.website,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'website': website,
      };
}
