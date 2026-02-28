import 'package:stronghold_core/stronghold_core.dart';

class SupplierService {
  final ApiClient _client;
  static const String _path = '/api/suppliers';

  SupplierService(this._client);

  Future<PagedResult<SupplierResponse>> getAll(SupplierQueryFilter filter) {
    return _client.get<PagedResult<SupplierResponse>>(
      _path,
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(json as Map<String, dynamic>, SupplierResponse.fromJson),
    );
  }

  Future<List<SupplierResponse>> getAllUnpaged(SupplierQueryFilter filter) {
    return _client.get<List<SupplierResponse>>(
      '$_path/all',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => (json as List).map((e) => SupplierResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<SupplierResponse> getById(int id) {
    return _client.get<SupplierResponse>(
      '$_path/$id',
      parser: (json) => SupplierResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<int> create(CreateSupplierRequest request) {
    return _client.post<int>(
      _path,
      body: request.toJson(),
      parser: (json) => json is Map<String, dynamic> ? json['id'] as int : json as int,
    );
  }

  Future<void> update(int id, UpdateSupplierRequest request) {
    return _client.put<void>(
      '$_path/$id',
      body: request.toJson(),
      parser: (_) {},
    );
  }

  Future<void> delete(int id) => _client.delete('$_path/$id');
}
