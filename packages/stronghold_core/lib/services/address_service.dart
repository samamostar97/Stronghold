import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/requests/upsert_address_request.dart';
import '../models/responses/address_response.dart';

class AddressService {
  final ApiClient _client;
  static const String _basePath = '/api/address';

  AddressService(this._client);

  /// Get the current user's delivery address.
  /// Returns null if no address has been saved yet.
  Future<AddressResponse?> getMyAddress() async {
    try {
      return await _client.get<AddressResponse>(
        '$_basePath/my',
        parser: (json) =>
            AddressResponse.fromJson(json as Map<String, dynamic>),
      );
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  /// Admin: get a specific user's delivery address.
  Future<AddressResponse?> getByUserId(int userId) async {
    try {
      return await _client.get<AddressResponse>(
        '$_basePath/$userId',
        parser: (json) =>
            AddressResponse.fromJson(json as Map<String, dynamic>),
      );
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
  }

  /// Create or update the current user's delivery address.
  Future<AddressResponse> upsertMyAddress(UpsertAddressRequest request) async {
    return _client.put<AddressResponse>(
      '$_basePath/my',
      body: request.toJson(),
      parser: (json) =>
          AddressResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
