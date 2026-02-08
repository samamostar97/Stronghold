import 'base_query_filter.dart';

/// Matches backend UserQueryFilter exactly
class UserQueryFilter extends BaseQueryFilter {
  /// Name filter - searches firstName/lastName/username
  final String? name;

  UserQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.name,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (name != null && name!.isNotEmpty) {
      params['name'] = name!;
    }
    return params;
  }

  @override
  UserQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    String? name,
  }) {
    return UserQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      name: name ?? this.name,
    );
  }
}
