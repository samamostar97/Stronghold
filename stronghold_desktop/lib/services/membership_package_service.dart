import 'package:stronghold_core/stronghold_core.dart';

class MembershipPackageService {
  final ApiClient _client;
  static const String _path = '/api/membership-packages';

  MembershipPackageService(this._client);

  Future<PagedResult<MembershipPackageResponse>> getAll(MembershipPackageQueryFilter filter) {
    return _client.get<PagedResult<MembershipPackageResponse>>(
      _path,
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(json as Map<String, dynamic>, MembershipPackageResponse.fromJson),
    );
  }

  Future<List<MembershipPackageResponse>> getAllUnpaged(MembershipPackageQueryFilter filter) {
    return _client.get<List<MembershipPackageResponse>>(
      '$_path/all',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => (json as List).map((e) => MembershipPackageResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<MembershipPackageResponse> getById(int id) {
    return _client.get<MembershipPackageResponse>(
      '$_path/$id',
      parser: (json) => MembershipPackageResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<int> create(CreateMembershipPackageRequest request) {
    return _client.post<int>(
      _path,
      body: request.toJson(),
      parser: (json) => json is Map<String, dynamic> ? json['id'] as int : json as int,
    );
  }

  Future<void> update(int id, UpdateMembershipPackageRequest request) {
    return _client.put<void>(
      '$_path/$id',
      body: request.toJson(),
      parser: (_) {},
    );
  }

  Future<void> delete(int id) => _client.delete('$_path/$id');
}
