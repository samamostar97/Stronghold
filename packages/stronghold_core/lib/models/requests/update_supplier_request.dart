/// Matches backend UpdateSupplierRequest exactly
class UpdateSupplierRequest {
  final String? name;
  final String? website;

  const UpdateSupplierRequest({
    this.name,
    this.website,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (website != null) map['website'] = website;
    return map;
  }
}
