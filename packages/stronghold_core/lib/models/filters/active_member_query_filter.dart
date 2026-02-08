import 'base_query_filter.dart';

/// Filter for active members query.
/// Maps `search` to backend's `Name` query parameter.
class ActiveMemberQueryFilter extends BaseQueryFilter {
  ActiveMemberQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      if (search != null && search!.isNotEmpty) 'name': search!,
    };
  }

  @override
  ActiveMemberQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    return ActiveMemberQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
    );
  }
}
