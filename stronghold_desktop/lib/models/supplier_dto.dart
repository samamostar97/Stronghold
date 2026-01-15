class SupplierDTO {
  final int id;
  final String name;
  final String? website;



  const SupplierDTO({
    required this.id,
    required this.name,
    this.website,
  });

  factory SupplierDTO.fromJson(Map<String, dynamic> json) {
    return SupplierDTO(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      website:(json['website'] ?? '') as String,
    );
  }
}

class CreateSupplierDTO {
  final String name;
  final String? website;



  const CreateSupplierDTO({
    required this.name,
    this.website,

  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'website' : website,
      };
}

class UpdateSupplierDTO {
  final String? name;
  final String? website;


  const UpdateSupplierDTO({
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
