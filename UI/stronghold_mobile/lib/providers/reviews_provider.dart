import 'package:flutter/foundation.dart';

import '../models/paged_result.dart';
import '../models/review.dart';
import '../utils/api_client.dart';

class ReviewsProvider extends ChangeNotifier {
  final ApiClient _api;

  ReviewsProvider(this._api);

  List<Review> _myReviews = [];

  List<Review> get myReviews => _myReviews;

  bool hasReviewed(int supplementId) =>
      _myReviews.any((r) => r.supplementId == supplementId);

  Future<void> loadMine() async {
    final data = await _api.get('/api/reviews/my') as List;
    _myReviews = data
        .map((item) => Review.fromJson(item as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  /// Recenzije jednog proizvoda - za detalje u prodavnici.
  Future<List<Review>> loadForSupplement(int supplementId) async {
    final data = await _api.get('/api/reviews', query: {
      'page': '1',
      'pageSize': '20',
      'supplementId': '$supplementId',
    }) as Map<String, dynamic>;
    return PagedResult.fromJson(data, Review.fromJson).items;
  }

  Future<void> create({
    required int supplementId,
    required int rating,
    String? comment,
  }) async {
    await _api.post('/api/reviews/my', body: {
      'supplementId': supplementId,
      'rating': rating,
      'comment': comment,
    });
    await loadMine();
  }
}
