import '../api/api_client.dart';
import '../models/common/paged_result.dart';
import '../models/filters/base_query_filter.dart';

/// Generic CRUD service that eliminates duplicate code across entity services.
/// Matches backend BaseService<TEntity, TResponse, TCreate, TUpdate, TFilter, TKey> pattern.
abstract class CrudService<TResponse, TCreate, TUpdate, TFilter extends BaseQueryFilter> {
  final ApiClient _client;
  final String _basePath;
  final String _getAllPath;
  final TResponse Function(Map<String, dynamic>) _responseParser;

  CrudService({
    required ApiClient client,
    required String basePath,
    required TResponse Function(Map<String, dynamic>) responseParser,
  })  : _client = client,
        _basePath = basePath,
        _getAllPath = '$basePath/GetAllPaged',
        _responseParser = responseParser;

  /// Get paginated list with server-side filtering and sorting
  Future<PagedResult<TResponse>> getAll(TFilter filter) async {
    return _client.get<PagedResult<TResponse>>(
      _getAllPath,
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(
        json as Map<String, dynamic>,
        _responseParser,
      ),
    );
  }

  /// Get single entity by ID
  Future<TResponse> getById(int id) async {
    return _client.get<TResponse>(
      '$_basePath/$id',
      parser: (json) => _responseParser(json as Map<String, dynamic>),
    );
  }

  /// Create new entity, returns created ID
  Future<int> create(TCreate request) async {
    return _client.post<int>(
      _basePath,
      body: toCreateJson(request),
      parser: (json) {
        // Backend returns full object via CreatedAtAction, extract the id
        if (json is Map<String, dynamic>) {
          return json['id'] as int;
        }
        // Fallback if backend returns just the id
        return json as int;
      },
    );
  }

  /// Update existing entity
  Future<void> update(int id, TUpdate request) async {
    await _client.put<void>(
      '$_basePath/$id',
      body: toUpdateJson(request),
      parser: (_) {},
    );
  }

  /// Delete entity by ID
  Future<void> delete(int id) async {
    await _client.delete('$_basePath/$id');
  }

  /// Convert create request to JSON - override in subclass
  Map<String, dynamic> toCreateJson(TCreate request);

  /// Convert update request to JSON - override in subclass
  Map<String, dynamic> toUpdateJson(TUpdate request);
}

/// CRUD service with image upload support
abstract class CrudServiceWithImage<TResponse, TCreate, TUpdate, TFilter extends BaseQueryFilter>
    extends CrudService<TResponse, TCreate, TUpdate, TFilter> {
  CrudServiceWithImage({
    required super.client,
    required super.basePath,
    required super.responseParser,
  });

  /// Upload image for entity
  Future<String> uploadImage(int id, String filePath) async {
    return _client.uploadFile<String>(
      '$_basePath/$id/image',
      filePath,
      'file',
      parser: (json) => json as String,
    );
  }

  /// Delete image for entity
  Future<void> deleteImage(int id) async {
    await _client.delete('$_basePath/$id/image');
  }
}
