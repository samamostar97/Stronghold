/// Matches backend SupplementCategoryResponse
class SupplementCategoryResponse {
  final int id;
  final String name;

  const SupplementCategoryResponse({
    required this.id,
    required this.name,
  });

  factory SupplementCategoryResponse.fromJson(Map<String, dynamic> json) {
    return SupplementCategoryResponse(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
    );
  }
}
