/// Matches backend UpdateSupplementCategoryRequest exactly
class UpdateSupplementCategoryRequest {
  final String? name;

  const UpdateSupplementCategoryRequest({
    this.name,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    return map;
  }
}
