import 'base_query_filter.dart';

/// Filter for membership payments query
class MembershipQueryFilter extends BaseQueryFilter {
  MembershipQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
  });

  @override
  MembershipQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    return MembershipQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
