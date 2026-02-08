import 'package:stronghold_core/stronghold_core.dart';

/// Generic state for paginated lists with server-side filtering/sorting
class ListState<T, TFilter extends BaseQueryFilter> {
  final PagedResult<T>? data;
  final bool isLoading;
  final String? error;
  final TFilter filter;

  const ListState({
    this.data,
    this.isLoading = false,
    this.error,
    required this.filter,
  });

  /// Initial loading state
  ListState<T, TFilter> copyWithLoading() {
    return ListState(
      data: data,
      isLoading: true,
      error: null,
      filter: filter,
    );
  }

  /// Successful data load
  ListState<T, TFilter> copyWithData(PagedResult<T> newData) {
    return ListState(
      data: newData,
      isLoading: false,
      error: null,
      filter: filter,
    );
  }

  /// Error state
  ListState<T, TFilter> copyWithError(String errorMessage) {
    return ListState(
      data: data,
      isLoading: false,
      error: errorMessage,
      filter: filter,
    );
  }

  /// Update filter (triggers reload)
  ListState<T, TFilter> copyWithFilter(TFilter newFilter) {
    return ListState(
      data: data,
      isLoading: isLoading,
      error: error,
      filter: newFilter,
    );
  }

  // Convenience getters
  List<T> get items => data?.items ?? [];
  int get totalCount => data?.totalCount ?? 0;
  int get currentPage => filter.pageNumber;
  int get pageSize => filter.pageSize;
  int get totalPages => data?.totalPages(pageSize) ?? 1;
  bool get hasNextPage => data?.hasNextPage(pageSize) ?? false;
  bool get hasPreviousPage => data?.hasPreviousPage ?? false;
  bool get isEmpty => data?.isEmpty ?? true;
  bool get isNotEmpty => data?.isNotEmpty ?? false;
}
