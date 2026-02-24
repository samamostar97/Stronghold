import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// Supplement list state
class SupplementListState {
  final List<SupplementResponse> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final String? search;
  final int? categoryId;
  final bool isLoading;
  final String? error;

  const SupplementListState({
    this.items = const <SupplementResponse>[],
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.search,
    this.categoryId,
    this.isLoading = false,
    this.error,
  });

  SupplementListState copyWith({
    List<SupplementResponse>? items,
    int? totalCount,
    int? pageNumber,
    int? pageSize,
    String? search,
    int? categoryId,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearCategory = false,
    bool clearSearch = false,
  }) {
    return SupplementListState(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: clearSearch ? null : (search ?? this.search),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasNextPage => pageNumber < totalPages;
  bool get hasPreviousPage => pageNumber > 1;
}

/// Supplement list notifier
class SupplementListNotifier extends StateNotifier<SupplementListState> {
  final SupplementService _service;

  SupplementListNotifier(this._service) : super(const SupplementListState());

  /// Load supplements
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final filter = SupplementQueryFilter()
        ..pageNumber = state.pageNumber
        ..pageSize = state.pageSize;
      if (state.search != null && state.search!.isNotEmpty) {
        filter.search = state.search;
      }
      if (state.categoryId != null) {
        filter.supplementCategoryId = state.categoryId;
      }

      final result = await _service.getAll(filter);

      state = state.copyWith(
        items: result.items,
        totalCount: result.totalCount,
        pageNumber: result.pageNumber,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom ucitavanja suplemenata',
        isLoading: false,
      );
    }
  }

  /// Set search and reload from page 1
  Future<void> setSearch(String? search) async {
    state = state.copyWith(
      search: search,
      pageNumber: 1,
      clearSearch: search == null || search.isEmpty,
    );
    await load();
  }

  /// Set category filter and reload from page 1
  Future<void> setCategory(int? categoryId) async {
    state = state.copyWith(
      categoryId: categoryId,
      pageNumber: 1,
      clearCategory: categoryId == null,
    );
    await load();
  }

  /// Go to next page
  Future<void> nextPage() async {
    if (state.hasNextPage) {
      state = state.copyWith(pageNumber: state.pageNumber + 1);
      await load();
    }
  }

  /// Go to previous page
  Future<void> previousPage() async {
    if (state.hasPreviousPage) {
      state = state.copyWith(pageNumber: state.pageNumber - 1);
      await load();
    }
  }

  /// Refresh current page
  Future<void> refresh() => load();
}

/// Supplement list provider
final supplementListProvider =
    StateNotifierProvider<SupplementListNotifier, SupplementListState>((ref) {
  final client = ref.watch(apiClientProvider);
  return SupplementListNotifier(SupplementService(client));
});

/// Single supplement detail provider
final supplementDetailProvider =
    FutureProvider.family<SupplementResponse, int>((ref, id) async {
  final client = ref.watch(apiClientProvider);
  return SupplementService(client).getById(id);
});

/// Supplement categories provider
final supplementCategoriesProvider =
    FutureProvider<List<SupplementCategoryResponse>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final filter = SupplementCategoryQueryFilter()..pageSize = 100;
  final result = await SupplementCategoryService(client).getAll(filter);
  return result.items;
});

/// Supplement reviews provider
final supplementReviewsProvider =
    FutureProvider.family<List<SupplementReviewResponse>, int>((ref, supplementId) async {
  final client = ref.watch(apiClientProvider);
  return SupplementService(client).getReviews(supplementId);
});
