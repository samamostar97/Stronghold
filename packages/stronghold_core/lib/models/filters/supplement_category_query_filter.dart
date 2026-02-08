import 'base_query_filter.dart';

/// Matches backend SupplementCategoryQueryFilter exactly
class SupplementCategoryQueryFilter extends BaseQueryFilter {
  SupplementCategoryQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
  });

  @override
  SupplementCategoryQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    return SupplementCategoryQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
