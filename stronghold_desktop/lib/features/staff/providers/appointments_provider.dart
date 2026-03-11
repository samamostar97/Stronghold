import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/appointments_repository.dart';
import '../models/appointment_response.dart';

final appointmentsRepositoryProvider = Provider((ref) => AppointmentsRepository());

class AppointmentsFilter {
  final int pageNumber;
  final String? search;
  final String? statusFilter;

  const AppointmentsFilter({
    this.pageNumber = 1,
    this.search,
    this.statusFilter,
  });

  AppointmentsFilter copyWith({
    int? pageNumber,
    String? search,
    String? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return AppointmentsFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }
}

// Active appointments filter
class AppointmentsFilterNotifier extends Notifier<AppointmentsFilter> {
  @override
  AppointmentsFilter build() => const AppointmentsFilter();

  void update(AppointmentsFilter filter) => state = filter;
}

final appointmentsFilterProvider =
    NotifierProvider<AppointmentsFilterNotifier, AppointmentsFilter>(
        AppointmentsFilterNotifier.new);

// Appointment history filter
class AppointmentHistoryFilterNotifier extends Notifier<AppointmentsFilter> {
  @override
  AppointmentsFilter build() => const AppointmentsFilter();

  void update(AppointmentsFilter filter) => state = filter;
}

final appointmentHistoryFilterProvider =
    NotifierProvider<AppointmentHistoryFilterNotifier, AppointmentsFilter>(
        AppointmentHistoryFilterNotifier.new);

// Active appointments (Pending + Approved)
final appointmentsProvider =
    FutureProvider.autoDispose<PagedAppointmentResponse>((ref) async {
  final repo = ref.read(appointmentsRepositoryProvider);
  final filter = ref.watch(appointmentsFilterProvider);

  if (filter.statusFilter != null) {
    return repo.getAppointments(
      pageNumber: filter.pageNumber,
      search: filter.search,
      status: filter.statusFilter,
      orderBy: 'status',
      orderDescending: false,
    );
  }

  // No filter — fetch Pending first, then Approved
  final pendingResult = await repo.getAppointments(
    pageNumber: filter.pageNumber,
    search: filter.search,
    status: 'Pending',
    orderDescending: true,
  );

  final approvedResult = await repo.getAppointments(
    pageNumber: 1,
    pageSize: 100,
    search: filter.search,
    status: 'Approved',
    orderDescending: true,
  );

  final allItems = [...pendingResult.items, ...approvedResult.items];
  final totalCount = pendingResult.totalCount + approvedResult.totalCount;

  return PagedAppointmentResponse(
    items: allItems,
    totalCount: totalCount,
    currentPage: filter.pageNumber,
    totalPages: (totalCount / 10).ceil(),
    pageSize: 10,
  );
});

// Appointment history (Completed + Rejected)
final appointmentHistoryProvider =
    FutureProvider.autoDispose<PagedAppointmentResponse>((ref) async {
  final repo = ref.read(appointmentsRepositoryProvider);
  final filter = ref.watch(appointmentHistoryFilterProvider);

  if (filter.statusFilter != null) {
    return repo.getAppointments(
      pageNumber: filter.pageNumber,
      search: filter.search,
      status: filter.statusFilter,
      orderDescending: true,
    );
  }

  // No filter — fetch both Completed and Rejected
  final completedResult = await repo.getAppointments(
    pageNumber: filter.pageNumber,
    search: filter.search,
    status: 'Completed',
    orderDescending: true,
  );

  final rejectedResult = await repo.getAppointments(
    pageNumber: 1,
    pageSize: 100,
    search: filter.search,
    status: 'Rejected',
    orderDescending: true,
  );

  final allItems = [...completedResult.items, ...rejectedResult.items];
  // Sort by scheduledAt descending
  allItems.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
  final totalCount = completedResult.totalCount + rejectedResult.totalCount;

  return PagedAppointmentResponse(
    items: allItems,
    totalCount: totalCount,
    currentPage: filter.pageNumber,
    totalPages: (totalCount / 10).ceil(),
    pageSize: 10,
  );
});
