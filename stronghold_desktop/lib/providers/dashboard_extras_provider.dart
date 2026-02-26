import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'appointment_provider.dart';
import 'seminar_provider.dart';
import 'membership_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UPCOMING APPOINTMENTS
// ─────────────────────────────────────────────────────────────────────────────

class DashboardAppointmentsState {
  final List<AdminAppointmentResponse> items;
  final bool isLoading;
  final String? error;

  const DashboardAppointmentsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardAppointmentsState copyWith({
    List<AdminAppointmentResponse>? items,
    bool? isLoading,
    String? error,
  }) {
    return DashboardAppointmentsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardAppointmentsNotifier
    extends StateNotifier<DashboardAppointmentsState> {
  final AppointmentService _service;

  DashboardAppointmentsNotifier(this._service)
      : super(const DashboardAppointmentsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _service.getAll(
        AppointmentQueryFilter(pageSize: 50, orderBy: 'date'),
      );
      final now = DateTime.now();
      final upcoming = result.items
          .where((a) => a.appointmentDate.isAfter(now))
          .take(10)
          .toList();
      if (mounted) {
        state = state.copyWith(items: upcoming, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }
}

final dashboardAppointmentsProvider = StateNotifierProvider<
    DashboardAppointmentsNotifier, DashboardAppointmentsState>((ref) {
  return DashboardAppointmentsNotifier(ref.watch(appointmentServiceProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// UPCOMING SEMINARS
// ─────────────────────────────────────────────────────────────────────────────

class DashboardSeminarsState {
  final List<SeminarResponse> items;
  final bool isLoading;
  final String? error;

  const DashboardSeminarsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardSeminarsState copyWith({
    List<SeminarResponse>? items,
    bool? isLoading,
    String? error,
  }) {
    return DashboardSeminarsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardSeminarsNotifier
    extends StateNotifier<DashboardSeminarsState> {
  final SeminarService _service;

  DashboardSeminarsNotifier(this._service)
      : super(const DashboardSeminarsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _service.getAll(
        SeminarQueryFilter(pageSize: 10, status: 'active', orderBy: 'eventdate'),
      );
      if (mounted) {
        state = state.copyWith(items: result.items, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }
}

final dashboardSeminarsProvider = StateNotifierProvider<
    DashboardSeminarsNotifier, DashboardSeminarsState>((ref) {
  return DashboardSeminarsNotifier(ref.watch(seminarServiceProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// EXPIRING MEMBERSHIPS
// ─────────────────────────────────────────────────────────────────────────────

class DashboardExpiringMembershipsState {
  final List<ActiveMemberResponse> items;
  final bool isLoading;
  final String? error;

  const DashboardExpiringMembershipsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardExpiringMembershipsState copyWith({
    List<ActiveMemberResponse>? items,
    bool? isLoading,
    String? error,
  }) {
    return DashboardExpiringMembershipsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardExpiringMembershipsNotifier
    extends StateNotifier<DashboardExpiringMembershipsState> {
  final MembershipService _service;

  DashboardExpiringMembershipsNotifier(this._service)
      : super(const DashboardExpiringMembershipsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _service.getActiveMembers(
        ActiveMemberQueryFilter(pageSize: 100),
      );
      final cutoff = DateTime.now().add(const Duration(days: 7));
      final expiring = result.items
          .where((m) => m.membershipEndDate.isBefore(cutoff))
          .toList()
        ..sort((a, b) => a.membershipEndDate.compareTo(b.membershipEndDate));
      if (mounted) {
        state = state.copyWith(items: expiring, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }
}

final dashboardExpiringMembershipsProvider = StateNotifierProvider<
    DashboardExpiringMembershipsNotifier,
    DashboardExpiringMembershipsState>((ref) {
  return DashboardExpiringMembershipsNotifier(
      ref.watch(membershipServiceProvider));
});
