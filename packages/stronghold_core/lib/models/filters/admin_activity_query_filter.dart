import 'base_query_filter.dart';

class AdminActivityQueryFilter extends BaseQueryFilter {
  String? actionType;
  String? entityType;

  AdminActivityQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.actionType,
    this.entityType,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (actionType != null && actionType!.isNotEmpty) {
      params['actionType'] = actionType!;
    }
    if (entityType != null && entityType!.isNotEmpty) {
      params['entityType'] = entityType!;
    }
    return params;
  }

  @override
  AdminActivityQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    String? actionType,
    String? entityType,
  }) {
    return AdminActivityQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      actionType: actionType ?? this.actionType,
      entityType: entityType ?? this.entityType,
    );
  }
}
