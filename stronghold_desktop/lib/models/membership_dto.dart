class MembershipPaymentRowDTO {
  final int id;
  final String packageName;
  final double amountPaid;
  final DateTime paymentDate;
  final DateTime startDate;
  final DateTime endDate;

  const MembershipPaymentRowDTO({
    required this.id,
    required this.packageName,
    required this.amountPaid,
    required this.paymentDate,
    required this.startDate,
    required this.endDate,
  });

  factory MembershipPaymentRowDTO.fromJson(Map<String, dynamic> json) {
    return MembershipPaymentRowDTO(
      id: (json['id'] ?? 0) as int,
      packageName: (json['packageName'] ?? '') as String,
      amountPaid: ((json['amountPaid'] ?? 0) as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }
}

class PagedMembershipPaymentsResult {
  final List<MembershipPaymentRowDTO> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedMembershipPaymentsResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedMembershipPaymentsResult.fromJson(Map<String, dynamic> json, int pageSize) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => MembershipPaymentRowDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <MembershipPaymentRowDTO>[];

    final totalCount = (json['totalCount'] ?? 0) as int;
    final totalPages = totalCount > 0 ? ((totalCount / pageSize).ceil()) : 1;

    return PagedMembershipPaymentsResult(
      items: itemsList,
      totalCount: totalCount,
      pageNumber: (json['pageNumber'] ?? 1) as int,
      pageSize: pageSize,
      totalPages: totalPages,
    );
  }
}
