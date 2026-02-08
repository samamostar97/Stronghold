import 'base_query_filter.dart';

/// Matches backend MembershipPackageQueryFilter exactly
class MembershipPackageQueryFilter extends BaseQueryFilter {
  MembershipPackageQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
  });

  @override
  MembershipPackageQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    return MembershipPackageQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
