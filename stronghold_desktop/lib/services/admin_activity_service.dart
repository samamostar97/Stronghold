import 'package:stronghold_core/stronghold_core.dart';

class AdminActivityService {
  final ApiClient _client;
  static const String _basePath = '/api/admin-activities';

  AdminActivityService(this._client);

  Future<List<AdminActivityResponse>> getRecent({int count = 20}) async {
    return _client.get<List<AdminActivityResponse>>(
      '$_basePath/recent',
      queryParameters: {'count': count.toString()},
      parser: (json) => (json as List<dynamic>)
          .map((e) => AdminActivityResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<AdminActivityResponse> undo(int id) async {
    return _client.post<AdminActivityResponse>(
      '$_basePath/$id/undo',
      body: const {},
      parser: (json) =>
          AdminActivityResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
