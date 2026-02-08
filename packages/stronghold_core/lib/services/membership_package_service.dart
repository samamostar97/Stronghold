import '../api/api_client.dart';
import 'crud_service.dart';
import '../models/responses/membership_package_response.dart';
import '../models/requests/create_membership_package_request.dart';
import '../models/requests/update_membership_package_request.dart';
import '../models/filters/membership_package_query_filter.dart';

/// Membership package service using new generic CRUD pattern
class MembershipPackageService extends CrudService<
    MembershipPackageResponse,
    CreateMembershipPackageRequest,
    UpdateMembershipPackageRequest,
    MembershipPackageQueryFilter> {
  MembershipPackageService(ApiClient client)
      : super(
          client: client,
          basePath: '/api/membership-packages',
          responseParser: MembershipPackageResponse.fromJson,
        );

  @override
  Map<String, dynamic> toCreateJson(CreateMembershipPackageRequest request) =>
      request.toJson();

  @override
  Map<String, dynamic> toUpdateJson(UpdateMembershipPackageRequest request) =>
      request.toJson();
}
