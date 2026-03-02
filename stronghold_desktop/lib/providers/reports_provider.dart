import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../services/services.dart';
import 'api_providers.dart';

/// Reports service provider
final reportsServiceProvider = Provider<ReportsService>((ref) {
  return ReportsService(ref.watch(apiClientProvider));
});

/// Business report provider — fetches business report for last 30 days (default)
final businessReportProvider = FutureProvider<BusinessReportDTO>((ref) async {
  final service = ref.watch(reportsServiceProvider);
  return service.getBusinessReport();
});

/// Staff report provider — fetches staff analytics for last 30 days
final staffReportProvider = FutureProvider<StaffReportDTO>((ref) async {
  final service = ref.watch(reportsServiceProvider);
  return service.getStaffReport();
});

/// Selected membership revenue period (in days)
final membershipRevenuePeriodProvider = StateProvider<int>((ref) => 90);

/// Membership popularity report provider (reacts to period change)
final membershipPopularityReportProvider =
    FutureProvider<MembershipPopularityReportDTO>((ref) async {
      final days = ref.watch(membershipRevenuePeriodProvider);
      final service = ref.watch(reportsServiceProvider);
      return service.getMembershipPopularityReport(days: days);
    });

/// Export operations notifier for handling export state
class ExportOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final ReportsService _service;

  ExportOperationsNotifier(this._service) : super(const AsyncValue.data(null));

  bool get isExporting => state.isLoading;

  Future<void> exportBusinessToExcel(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportBusinessToExcel(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportBusinessToPdf(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportBusinessToPdf(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportStaffToExcel(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportStaffToExcel(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportStaffToPdf(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportStaffToPdf(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportMembershipToExcel(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportMembershipToExcel(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportMembershipToPdf(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportMembershipToPdf(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportVisitsToExcel(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportVisitsToExcel(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportVisitsToPdf(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportVisitsToPdf(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportMembershipPaymentsToExcel(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportMembershipPaymentsToExcel(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> exportMembershipPaymentsToPdf(String savePath) async {
    state = const AsyncValue.loading();
    try {
      await _service.exportMembershipPaymentsToPdf(savePath);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Export operations provider
final exportOperationsProvider =
    StateNotifierProvider<ExportOperationsNotifier, AsyncValue<void>>((ref) {
      final service = ref.watch(reportsServiceProvider);
      return ExportOperationsNotifier(service);
    });
