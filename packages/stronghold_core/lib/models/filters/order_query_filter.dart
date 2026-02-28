import 'base_query_filter.dart';
import '../responses/order_response.dart';

/// Matches backend OrderQueryFilter exactly
class OrderQueryFilter extends BaseQueryFilter {
  OrderStatus? status;
  int? userId;
  bool descending;

  OrderQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.status,
    this.userId,
    this.descending = true,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();

    if (status != null) {
      params['status'] = status!.index.toString();
    }
    if (userId != null) {
      params['userId'] = userId.toString();
    }
    params['descending'] = descending.toString();

    return params;
  }

  @override
  OrderQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    OrderStatus? status,
    int? userId,
    bool? descending,
  }) {
    return OrderQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      descending: descending ?? this.descending,
    );
  }
}
