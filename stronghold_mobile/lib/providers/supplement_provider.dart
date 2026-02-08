import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../models/supplement_models.dart';
import 'api_providers.dart';

/// Supplement list state
class SupplementListState {
  final List<Supplement> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final String? search;
  final int? categoryId;
  final bool isLoading;
  final String? error;

  const SupplementListState({
    this.items = const [],
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.search,
    this.categoryId,
    this.isLoading = false,
    this.error,
  });

  SupplementListState copyWith({
    List<Supplement>? items,
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

/// Supplement list notifier - uses /api/supplements endpoints
class SupplementListNotifier extends StateNotifier<SupplementListState> {
  final ApiClient _client;

  SupplementListNotifier(this._client) : super(const SupplementListState());

  /// Load supplements
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, String>{
        'pageNumber': state.pageNumber.toString(),
        'pageSize': state.pageSize.toString(),
      };
      if (state.search != null && state.search!.isNotEmpty) {
        queryParams['search'] = state.search!;
      }
      if (state.categoryId != null) {
        queryParams['categoryId'] = state.categoryId.toString();
      }

      final result = await _client.get<Map<String, dynamic>>(
        '/api/supplements/GetAllPaged',
        queryParameters: queryParams,
        parser: (json) => json as Map<String, dynamic>,
      );

      final itemsList = result['items'] as List<dynamic>;
      final supplements = itemsList
          .map((json) => Supplement.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        items: supplements,
        totalCount: result['totalCount'] as int,
        pageNumber: result['pageNumber'] as int,
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
  return SupplementListNotifier(client);
});

/// Single supplement detail provider
final supplementDetailProvider =
    FutureProvider.family<Supplement, int>((ref, id) async {
  final client = ref.watch(apiClientProvider);
  return client.get<Supplement>(
    '/api/supplements/$id',
    parser: (json) => Supplement.fromJson(json as Map<String, dynamic>),
  );
});

/// Supplement categories provider
final supplementCategoriesProvider =
    FutureProvider<List<SupplementCategory>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.get<List<SupplementCategory>>(
    '/api/supplement-categories/GetAll',
    parser: (json) => (json as List<dynamic>)
        .map((j) => SupplementCategory.fromJson(j as Map<String, dynamic>))
        .toList(),
  );
});

/// Supplement reviews provider
final supplementReviewsProvider =
    FutureProvider.family<List<SupplementReview>, int>((ref, supplementId) async {
  final client = ref.watch(apiClientProvider);
  return client.get<List<SupplementReview>>(
    '/api/supplements/$supplementId/reviews',
    parser: (json) => (json as List<dynamic>)
        .map((j) => SupplementReview.fromJson(j as Map<String, dynamic>))
        .toList(),
  );
});
