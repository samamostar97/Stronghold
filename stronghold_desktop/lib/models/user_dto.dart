class UserTableRowDTO {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  const UserTableRowDTO({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  factory UserTableRowDTO.fromJson(Map<String, dynamic> json) {
    return UserTableRowDTO(
      id: (json['id'] ?? 0) as int,
      username: (json['username'] ?? '') as String,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phoneNumber: (json['phoneNumber'] ?? '') as String,
    );
  }
}

class PagedUsersResult {
  final List<UserTableRowDTO> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedUsersResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedUsersResult.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => UserTableRowDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <UserTableRowDTO>[];

    return PagedUsersResult(
      items: itemsList,
      totalCount: (json['totalCount'] ?? 0) as int,
      pageNumber: (json['pageNumber'] ?? 1) as int,
      pageSize: (json['pageSize'] ?? 10) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
    );
  }
}

enum Gender { male, female, other }

enum Role { member, employee, admin }

class UserDetailsDTO {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final Gender gender;

  const UserDetailsDTO({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
  });

  factory UserDetailsDTO.fromJson(Map<String, dynamic> json) {
    final genderIndex = (json['gender'] ?? 0) as int;
    final safeGenderIndex = genderIndex.clamp(0, Gender.values.length - 1);
    return UserDetailsDTO(
      id: (json['id'] ?? 0) as int,
      username: (json['username'] ?? '') as String,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phoneNumber: (json['phoneNumber'] ?? '') as String,
      gender: Gender.values[safeGenderIndex],
    );
  }
}

class CreateUserDTO {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final Gender gender;
  final Role role;
  final String password;
  final String? profileImageUrl;

  const CreateUserDTO({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.role,
    required this.password,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'gender': gender.index,
        'role': role.index,
        'password': password,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      };
}

class UpdateUserDTO {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String? password;

  const UpdateUserDTO({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.password,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        if (password != null) 'password': password,
      };
}
