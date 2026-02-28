import 'package:stronghold_core/stronghold_core.dart';

/// Recommendation service for personalized supplement suggestions
class RecommendationService {
  final ApiClient _client;

  RecommendationService(this._client);

  /// Get personalized recommendations
  Future<List<RecommendationResponse>> getRecommendations(
      {int count = 6}) async {
    return _client.get<List<RecommendationResponse>>(
      '/api/recommendations/my',
      queryParameters: {'count': count.toString()},
      parser: (json) => (json as List<dynamic>)
          .map((j) =>
              RecommendationResponse.fromJson(j as Map<String, dynamic>))
          .toList(),
    );
  }
}
