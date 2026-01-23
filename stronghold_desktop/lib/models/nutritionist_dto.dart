class NutritionistDTO {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  const NutritionistDTO({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  factory NutritionistDTO.fromJson(Map<String, dynamic> json) {
    return NutritionistDTO(
      id: (json['id'] ?? 0) as int,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phoneNumber: (json['phoneNumber'] ?? '') as String,
    );
  }
}

class CreateNutritionistDTO {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  const CreateNutritionistDTO({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
      };
}

class UpdateNutritionistDTO {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;

  const UpdateNutritionistDTO({
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (email != null) map['email'] = email;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    return map;
  }
}

class PagedNutritionistsResult {
  final List<NutritionistDTO> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedNutritionistsResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedNutritionistsResult.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => NutritionistDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <NutritionistDTO>[];

    return PagedNutritionistsResult(
      items: itemsList,
      totalCount: (json['totalCount'] ?? 0) as int,
      pageNumber: (json['pageNumber'] ?? 1) as int,
      pageSize: (json['pageSize'] ?? 10) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
    );
  }
}
