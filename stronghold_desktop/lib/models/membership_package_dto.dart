class MembershipPackageDTO {
  final int id;
  final String packageName;
  final double packagePrice;
  final String description;
  final bool isActive;

  const MembershipPackageDTO({
    required this.id,
    required this.packageName,
    required this.packagePrice,
    required this.description,
    required this.isActive,
  });

  factory MembershipPackageDTO.fromJson(Map<String, dynamic> json) {
    return MembershipPackageDTO(
      id: (json['id'] ?? 0) as int,
      packageName: (json['packageName'] ?? '') as String,
      packagePrice: ((json['packagePrice'] ?? 0) as num).toDouble(),
      description: (json['description'] ?? '') as String,
      isActive: (json['isActive'] ?? true) as bool,
    );
  }
}

class CreateMembershipPackageDTO {
  final String packageName;
  final double packagePrice;
  final String description;

  const CreateMembershipPackageDTO({
    required this.packageName,
    required this.packagePrice,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'packagePrice': packagePrice,
        'description': description,
      };
}

class UpdateMembershipPackageDTO {
  final String packageName;
  final double packagePrice;
  final String description;
  final bool isActive;

  const UpdateMembershipPackageDTO({
    required this.packageName,
    required this.packagePrice,
    required this.description,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'packagePrice': packagePrice,
        'description': description,
        'isActive': isActive,
      };
}

class PagedPackagesResult {
  final List<MembershipPackageDTO> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedPackagesResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedPackagesResult.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => MembershipPackageDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <MembershipPackageDTO>[];

    return PagedPackagesResult(
      items: itemsList,
      totalCount: (json['totalCount'] ?? 0) as int,
      pageNumber: (json['pageNumber'] ?? 1) as int,
      pageSize: (json['pageSize'] ?? 10) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
    );
  }
}

class AddMembershipPaymentRequest {
  final int userId;
  final int membershipPackageId;
  final double amountPaid;
  final DateTime paymentDate;
  final DateTime startDate;
  final DateTime endDate;

  const AddMembershipPaymentRequest({
    required this.userId,
    required this.membershipPackageId,
    required this.amountPaid,
    required this.paymentDate,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'membershipPackageId': membershipPackageId,
        'amountPaid': amountPaid,
        'paymentDate': paymentDate.toIso8601String(),
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
}

