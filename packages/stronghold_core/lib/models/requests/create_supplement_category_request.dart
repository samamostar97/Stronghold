/// Matches backend CreateSupplementCategoryRequest exactly
class CreateSupplementCategoryRequest {
  final String name;

  const CreateSupplementCategoryRequest({
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
