import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'list_notifier.dart';
import 'list_state.dart';

/// Membership package service provider
final membershipPackageServiceProvider = Provider<MembershipPackageService>((ref) {
  return MembershipPackageService(ref.watch(apiClientProvider));
});
/// Membership package list state provider
final membershipPackageListProvider = StateNotifierProvider<
    MembershipPackageListNotifier,
    ListState<MembershipPackageResponse, MembershipPackageQueryFilter>>((ref) {
  final service = ref.watch(membershipPackageServiceProvider);
  return MembershipPackageListNotifier(service);
});

/// Membership package list notifier implementation
class MembershipPackageListNotifier extends ListNotifier<
    MembershipPackageResponse,
    CreateMembershipPackageRequest,
    UpdateMembershipPackageRequest,
    MembershipPackageQueryFilter> {
  MembershipPackageListNotifier(MembershipPackageService service)
      : super(
          service: service,
          initialFilter: MembershipPackageQueryFilter(),
        );
  @override
  MembershipPackageQueryFilter createFilterCopy({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    // null = keep old value, '' = clear search, 'value' = new search
    final searchValue = search == null ? state.filter.search : (search.isEmpty ? null : search);
    return MembershipPackageQueryFilter(
      pageNumber: pageNumber ?? state.filter.pageNumber,
      pageSize: pageSize ?? state.filter.pageSize,
      search: searchValue,
      orderBy: orderBy ?? state.filter.orderBy,
    );
  }
}
