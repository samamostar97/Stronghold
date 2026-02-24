import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// FAQ list state
class FaqListState {
  final List<FaqResponse> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final String? search;
  final bool isLoading;
  final String? error;

  const FaqListState({
    this.items = const <FaqResponse>[],
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.search,
    this.isLoading = false,
    this.error,
  });

  FaqListState copyWith({
    List<FaqResponse>? items,
    int? totalCount,
    int? pageNumber,
    int? pageSize,
    String? search,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSearch = false,
  }) {
    return FaqListState(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: clearSearch ? null : (search ?? this.search),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasNextPage => pageNumber < totalPages;
}

/// FAQ list notifier
class FaqListNotifier extends StateNotifier<FaqListState> {
  final FaqService _service;

  FaqListNotifier(this._service) : super(const FaqListState());

  /// Load FAQs
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final filter = FaqQueryFilter()
        ..pageNumber = state.pageNumber
        ..pageSize = state.pageSize;
      if (state.search != null && state.search!.isNotEmpty) {
        filter.search = state.search;
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
        error: 'Greska prilikom ucitavanja FAQ',
        isLoading: false,
      );
    }
  }

  /// Set search and reload
  Future<void> setSearch(String? search) async {
    state = state.copyWith(
      search: search,
      pageNumber: 1,
      clearSearch: search == null || search.isEmpty,
    );
    await load();
  }

  /// Refresh
  Future<void> refresh() => load();
}

/// FAQ list provider
final faqListProvider =
    StateNotifierProvider<FaqListNotifier, FaqListState>((ref) {
  final client = ref.watch(apiClientProvider);
  return FaqListNotifier(FaqService(client));
});

/// All FAQs provider (no pagination)
final allFaqsProvider = FutureProvider<List<FaqResponse>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final filter = FaqQueryFilter()
    ..pageNumber = 1
    ..pageSize = 200;
  return FaqService(client).getAllUnpaged(filter);
});
