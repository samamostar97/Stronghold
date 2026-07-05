class SupplementCategory {
  final int id;
  final String name;
  final String description;

  SupplementCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory SupplementCategory.fromJson(Map<String, dynamic> json) =>
      SupplementCategory(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
      );
}
