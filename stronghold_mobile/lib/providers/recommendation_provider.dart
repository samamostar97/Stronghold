import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// Recommendations provider
final recommendationsProvider =
    FutureProvider.family<List<RecommendationResponse>, int>((ref, count) async {
  final client = ref.watch(apiClientProvider);
  return RecommendationService(client).getRecommendations(count: count);
});

/// Default recommendations (6 items)
final defaultRecommendationsProvider =
    FutureProvider<List<RecommendationResponse>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return RecommendationService(client).getRecommendations(count: 6);
});
