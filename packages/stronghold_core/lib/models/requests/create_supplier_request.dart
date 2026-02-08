/// Matches backend CreateSupplierRequest exactly
class CreateSupplierRequest {
  final String name;
  final String? website;

  const CreateSupplierRequest({
    required this.name,
    this.website,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (website != null && website!.isNotEmpty) 'website': website,
      };
}
