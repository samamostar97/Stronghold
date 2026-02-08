import '../api/api_client.dart';
import 'crud_service.dart';
import '../models/responses/supplier_response.dart';
import '../models/requests/create_supplier_request.dart';
import '../models/requests/update_supplier_request.dart';
import '../models/filters/supplier_query_filter.dart';

/// Supplier service using new generic CRUD pattern
class SupplierService extends CrudService<
    SupplierResponse,
    CreateSupplierRequest,
    UpdateSupplierRequest,
    SupplierQueryFilter> {
  SupplierService(ApiClient client)
      : super(
          client: client,
          basePath: '/api/suppliers',
          responseParser: SupplierResponse.fromJson,
        );

  @override
  Map<String, dynamic> toCreateJson(CreateSupplierRequest request) =>
      request.toJson();

  @override
  Map<String, dynamic> toUpdateJson(UpdateSupplierRequest request) =>
      request.toJson();
}
