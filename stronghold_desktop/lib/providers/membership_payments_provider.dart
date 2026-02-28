import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../services/services.dart';
import 'membership_provider.dart';
import 'list_state.dart';

final membershipPaymentsProvider =
    StateNotifierProvider<
      MembershipPaymentsNotifier,
      ListState<AdminMembershipPaymentResponse, MembershipQueryFilter>
    >((ref) {
      final service = ref.watch(membershipServiceProvider);
      return MembershipPaymentsNotifier(service);
    });

class MembershipPaymentsNotifier
    extends
        StateNotifier<
          ListState<AdminMembershipPaymentResponse, MembershipQueryFilter>
        > {
  final MembershipService _service;

  MembershipPaymentsNotifier(this._service)
    : super(ListState(filter: MembershipQueryFilter(pageSize: 20)));

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await _service.getAllPayments(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    } catch (e) {
      state = state.copyWithError('Greska pri ucitavanju: $e');
    }
  }

  Future<void> refresh() => load();

  Future<void> setSearch(String? search) async {
    final normalizedSearch = search ?? '';
    final newFilter = state.filter.copyWith(
      pageNumber: 1,
      search: normalizedSearch,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  Future<void> setOrderBy(String? orderBy) async {
    final normalizedOrderBy = orderBy ?? '';
    final newFilter = state.filter.copyWith(
      pageNumber: 1,
      orderBy: normalizedOrderBy,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    final newFilter = state.filter.copyWith(pageNumber: page);
    state = state.copyWithFilter(newFilter);
    await load();
  }
}
