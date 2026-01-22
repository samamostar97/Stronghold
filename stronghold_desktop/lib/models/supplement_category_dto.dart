class SupplementCategoryDTO {
  final int id;
  final String name;

  const SupplementCategoryDTO({
    required this.id,
    required this.name,
  });

  factory SupplementCategoryDTO.fromJson(Map<String, dynamic> json) {
    return SupplementCategoryDTO(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
    );
  }
}
