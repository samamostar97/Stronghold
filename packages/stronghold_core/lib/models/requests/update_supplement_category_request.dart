/// Matches backend UpdateSupplementCategoryRequest exactly
class UpdateSupplementCategoryRequest {
  final String name;

  const UpdateSupplementCategoryRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
