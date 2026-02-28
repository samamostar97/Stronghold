import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../services/services.dart';
import 'api_providers.dart';
import 'list_notifier.dart';
import 'list_state.dart';

/// Membership package service provider
final membershipPackageServiceProvider = Provider<MembershipPackageService>((
  ref,
) {
  return MembershipPackageService(ref.watch(apiClientProvider));
});

/// Membership package list state provider
final membershipPackageListProvider =
    StateNotifierProvider<
      MembershipPackageListNotifier,
      ListState<MembershipPackageResponse, MembershipPackageQueryFilter>
    >((ref) {
      final service = ref.watch(membershipPackageServiceProvider);
      return MembershipPackageListNotifier(service);
    });

/// Membership package list notifier implementation
class MembershipPackageListNotifier
    extends
        ListNotifier<
          MembershipPackageResponse,
          CreateMembershipPackageRequest,
          UpdateMembershipPackageRequest,
          MembershipPackageQueryFilter
        > {
  MembershipPackageListNotifier(MembershipPackageService service)
    : super(
        getAll: service.getAll,
        create: service.create,
        update: service.update,
        delete: service.delete,
        initialFilter: MembershipPackageQueryFilter(),
      );
  @override
  MembershipPackageQueryFilter createFilterCopy({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    final normalizedSearch = search ?? state.filter.search;
    return state.filter.copyWith(
      pageNumber: pageNumber ?? state.filter.pageNumber,
      pageSize: pageSize ?? state.filter.pageSize,
      search: normalizedSearch,
      orderBy: orderBy ?? state.filter.orderBy,
    );
  }
}
