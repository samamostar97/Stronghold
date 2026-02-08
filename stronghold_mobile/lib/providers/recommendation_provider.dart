import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recommendation.dart';
import 'api_providers.dart';

/// Recommendations provider - uses /api/user/recommendations endpoint
/// This is the only endpoint with the /api/user/ prefix
final recommendationsProvider =
    FutureProvider.family<List<Recommendation>, int>((ref, count) async {
  final client = ref.watch(apiClientProvider);
  return client.get<List<Recommendation>>(
    '/api/user/recommendations',
    queryParameters: {'count': count.toString()},
    parser: (json) => (json as List<dynamic>)
        .map((j) => Recommendation.fromJson(j as Map<String, dynamic>))
        .toList(),
  );
});

/// Default recommendations (6 items)
final defaultRecommendationsProvider =
    FutureProvider<List<Recommendation>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.get<List<Recommendation>>(
    '/api/user/recommendations',
    queryParameters: {'count': '6'},
    parser: (json) => (json as List<dynamic>)
        .map((j) => Recommendation.fromJson(j as Map<String, dynamic>))
        .toList(),
  );
});
