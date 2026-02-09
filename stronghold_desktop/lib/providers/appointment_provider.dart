import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'list_state.dart';

/// Appointment service provider
final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService(ref.watch(apiClientProvider));
});

/// Appointment list state provider
final appointmentListProvider = StateNotifierProvider<
    AppointmentListNotifier,
    ListState<AdminAppointmentResponse, AppointmentQueryFilter>>((ref) {
  final service = ref.watch(appointmentServiceProvider);
  return AppointmentListNotifier(service);
});

/// Custom list notifier for appointments (read-only, no CrudService)
class AppointmentListNotifier extends StateNotifier<
    ListState<AdminAppointmentResponse, AppointmentQueryFilter>> {
  final AppointmentService _service;

  AppointmentListNotifier(this._service)
      : super(ListState(filter: AppointmentQueryFilter()));

  Future<void> load() async {
    state = state.copyWithLoading();
    try {
      final result = await _service.getAll(state.filter);
      state = state.copyWithData(result);
    } on ApiException catch (e) {
      state = state.copyWithError(e.message);
    } catch (e) {
      state = state.copyWithError('Greska pri ucitavanju: $e');
    }
  }

  Future<void> refresh() => load();

  Future<void> setSearch(String? search) async {
    final searchValue =
        search == null ? state.filter.search : (search.isEmpty ? null : search);
    final newFilter = AppointmentQueryFilter(
      pageNumber: 1,
      pageSize: state.filter.pageSize,
      search: searchValue,
      orderBy: state.filter.orderBy,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  Future<void> setOrderBy(String? orderBy) async {
    final newFilter = AppointmentQueryFilter(
      pageNumber: 1,
      pageSize: state.filter.pageSize,
      search: state.filter.search,
      orderBy: orderBy ?? state.filter.orderBy,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > state.totalPages) return;
    final newFilter = AppointmentQueryFilter(
      pageNumber: page,
      pageSize: state.filter.pageSize,
      search: state.filter.search,
      orderBy: state.filter.orderBy,
    );
    state = state.copyWithFilter(newFilter);
    await load();
  }
}
