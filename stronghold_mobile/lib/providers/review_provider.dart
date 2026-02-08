import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../models/review_models.dart';
import 'api_providers.dart';

/// My reviews state
class MyReviewsState {
  final List<Review> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final bool isLoading;
  final String? error;

  const MyReviewsState({
    this.items = const [],
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.isLoading = false,
    this.error,
  });

  MyReviewsState copyWith({
    List<Review>? items,
    int? totalCount,
    int? pageNumber,
    int? pageSize,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MyReviewsState(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasNextPage => pageNumber < totalPages;
}

/// My reviews notifier
class MyReviewsNotifier extends StateNotifier<MyReviewsState> {
  final ApiClient _client;

  MyReviewsNotifier(this._client) : super(const MyReviewsState());

  /// Load user's reviews
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, String>{
        'pageNumber': state.pageNumber.toString(),
        'pageSize': state.pageSize.toString(),
      };

      final result = await _client.get<Map<String, dynamic>>(
        '/api/reviews/my',
        queryParameters: queryParams,
        parser: (json) => json as Map<String, dynamic>,
      );

      final itemsList = result['items'] as List<dynamic>;
      final reviews = itemsList
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        items: reviews,
        totalCount: result['totalCount'] as int,
        pageNumber: result['pageNumber'] as int,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom ucitavanja recenzija',
        isLoading: false,
      );
    }
  }

  /// Delete review
  Future<void> delete(int id) async {
    try {
      await _client.delete('/api/reviews/$id');
      await load(); // Refresh list
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      rethrow;
    }
  }

  /// Go to next page (appends items for infinite scroll)
  Future<void> nextPage() async {
    if (!state.hasNextPage || state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final nextPageNumber = state.pageNumber + 1;
      final queryParams = <String, String>{
        'pageNumber': nextPageNumber.toString(),
        'pageSize': state.pageSize.toString(),
      };

      final result = await _client.get<Map<String, dynamic>>(
        '/api/reviews/my',
        queryParameters: queryParams,
        parser: (json) => json as Map<String, dynamic>,
      );

      final itemsList = result['items'] as List<dynamic>;
      final newReviews = itemsList
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        items: [...state.items, ...newReviews],
        totalCount: result['totalCount'] as int,
        pageNumber: result['pageNumber'] as int,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom ucitavanja recenzija',
        isLoading: false,
      );
    }
  }

  /// Refresh (resets to page 1)
  Future<void> refresh() async {
    state = state.copyWith(pageNumber: 1);
    await load();
  }
}

/// My reviews provider
final myReviewsProvider =
    StateNotifierProvider<MyReviewsNotifier, MyReviewsState>((ref) {
  final client = ref.watch(apiClientProvider);
  return MyReviewsNotifier(client);
});

/// Available supplements for review state
class AvailableSupplementsState {
  final List<PurchasedSupplement> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final bool isLoading;
  final String? error;

  const AvailableSupplementsState({
    this.items = const [],
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.isLoading = false,
    this.error,
  });

  AvailableSupplementsState copyWith({
    List<PurchasedSupplement>? items,
    int? totalCount,
    int? pageNumber,
    int? pageSize,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AvailableSupplementsState(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Available supplements for review notifier
class AvailableSupplementsNotifier extends StateNotifier<AvailableSupplementsState> {
  final ApiClient _client;

  AvailableSupplementsNotifier(this._client) : super(const AvailableSupplementsState());

  /// Load supplements available for review
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, String>{
        'pageNumber': state.pageNumber.toString(),
        'pageSize': state.pageSize.toString(),
      };

      final result = await _client.get<Map<String, dynamic>>(
        '/api/reviews/available-supplements',
        queryParameters: queryParams,
        parser: (json) => json as Map<String, dynamic>,
      );

      final itemsList = result['items'] as List<dynamic>;
      final supplements = itemsList
          .map((json) => PurchasedSupplement.fromJson(json as Map<String, dynamic>))
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

  /// Refresh
  Future<void> refresh() => load();
}

/// Available supplements for review provider
final availableSupplementsProvider =
    StateNotifierProvider<AvailableSupplementsNotifier, AvailableSupplementsState>((ref) {
  final client = ref.watch(apiClientProvider);
  return AvailableSupplementsNotifier(client);
});

/// Create review state
class CreateReviewState {
  final bool isLoading;
  final String? error;

  const CreateReviewState({this.isLoading = false, this.error});

  CreateReviewState copyWith({bool? isLoading, String? error, bool clearError = false}) {
    return CreateReviewState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Create review notifier
class CreateReviewNotifier extends StateNotifier<CreateReviewState> {
  final ApiClient _client;

  CreateReviewNotifier(this._client) : super(const CreateReviewState());

  /// Create review
  Future<void> create({
    required int supplementId,
    required int rating,
    String? comment,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _client.post<void>(
        '/api/reviews',
        body: {
          'supplementId': supplementId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
        parser: (_) {},
      );
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom kreiranja recenzije',
        isLoading: false,
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Create review provider
final createReviewProvider =
    StateNotifierProvider<CreateReviewNotifier, CreateReviewState>((ref) {
  final client = ref.watch(apiClientProvider);
  return CreateReviewNotifier(client);
});
