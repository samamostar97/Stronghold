import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../models/faq_models.dart';
import 'api_providers.dart';

/// FAQ list state
class FaqListState {
  final List<Faq> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final String? search;
  final bool isLoading;
  final String? error;

  const FaqListState({
    this.items = const [],
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.search,
    this.isLoading = false,
    this.error,
  });

  FaqListState copyWith({
    List<Faq>? items,
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
  final ApiClient _client;

  FaqListNotifier(this._client) : super(const FaqListState());

  /// Load FAQs
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

      final result = await _client.get<Map<String, dynamic>>(
        '/api/faq/GetAllPaged',
        queryParameters: queryParams,
        parser: (json) => json as Map<String, dynamic>,
      );

      final itemsList = result['items'] as List<dynamic>;
      final faqs = itemsList
          .map((json) => Faq.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        items: faqs,
        totalCount: result['totalCount'] as int,
        pageNumber: result['pageNumber'] as int,
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
  return FaqListNotifier(client);
});

/// All FAQs provider (no pagination)
final allFaqsProvider = FutureProvider<List<Faq>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.get<List<Faq>>(
    '/api/faq/GetAll',
    parser: (json) => (json as List<dynamic>)
        .map((j) => Faq.fromJson(j as Map<String, dynamic>))
        .toList(),
  );
});
