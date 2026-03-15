import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/reports_repository.dart';
import '../models/report_data.dart';

final reportsRepositoryProvider = Provider((ref) => ReportsRepository());

class ReportDateRange {
  final DateTime from;
  final DateTime to;

  const ReportDateRange({required this.from, required this.to});

  ReportDateRange copyWith({DateTime? from, DateTime? to}) {
    return ReportDateRange(
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}

// Separate date range notifiers per report screen
class RevenueDateRangeNotifier extends Notifier<ReportDateRange> {
  @override
  ReportDateRange build() {
    final now = DateTime.now();
    return ReportDateRange(
      from: DateTime(now.year, now.month - 3, now.day),
      to: now,
    );
  }

  void update(ReportDateRange range) => state = range;
}

final revenueDateRangeProvider =
    NotifierProvider<RevenueDateRangeNotifier, ReportDateRange>(
        RevenueDateRangeNotifier.new);

class UserDateRangeNotifier extends Notifier<ReportDateRange> {
  @override
  ReportDateRange build() {
    final now = DateTime.now();
    return ReportDateRange(
      from: DateTime(now.year, now.month - 3, now.day),
      to: now,
    );
  }

  void update(ReportDateRange range) => state = range;
}

final userDateRangeProvider =
    NotifierProvider<UserDateRangeNotifier, ReportDateRange>(
        UserDateRangeNotifier.new);

class ProductDateRangeNotifier extends Notifier<ReportDateRange> {
  @override
  ReportDateRange build() {
    final now = DateTime.now();
    return ReportDateRange(
      from: DateTime(now.year, now.month - 3, now.day),
      to: now,
    );
  }

  void update(ReportDateRange range) => state = range;
}

final productDateRangeProvider =
    NotifierProvider<ProductDateRangeNotifier, ReportDateRange>(
        ProductDateRangeNotifier.new);

class AppointmentDateRangeNotifier extends Notifier<ReportDateRange> {
  @override
  ReportDateRange build() {
    final now = DateTime.now();
    return ReportDateRange(
      from: DateTime(now.year, now.month - 3, now.day),
      to: now,
    );
  }

  void update(ReportDateRange range) => state = range;
}

final appointmentDateRangeProvider =
    NotifierProvider<AppointmentDateRangeNotifier, ReportDateRange>(
        AppointmentDateRangeNotifier.new);

// Data providers
final revenueReportProvider =
    FutureProvider.autoDispose<RevenueReportData>((ref) async {
  final repo = ref.read(reportsRepositoryProvider);
  final range = ref.watch(revenueDateRangeProvider);
  return repo.getRevenueReport(from: range.from, to: range.to);
});

final orderRevenueReportProvider =
    FutureProvider.autoDispose<OrderRevenueReportData>((ref) async {
  final repo = ref.read(reportsRepositoryProvider);
  final range = ref.watch(revenueDateRangeProvider);
  return repo.getOrderRevenueReport(from: range.from, to: range.to);
});

final membershipRevenueReportProvider =
    FutureProvider.autoDispose<MembershipRevenueReportData>((ref) async {
  final repo = ref.read(reportsRepositoryProvider);
  final range = ref.watch(revenueDateRangeProvider);
  return repo.getMembershipRevenueReport(from: range.from, to: range.to);
});

final usersReportProvider =
    FutureProvider.autoDispose<UsersReportData>((ref) async {
  final repo = ref.read(reportsRepositoryProvider);
  final range = ref.watch(userDateRangeProvider);
  return repo.getUsersReport(from: range.from, to: range.to);
});

final productsReportProvider =
    FutureProvider.autoDispose<ProductsReportData>((ref) async {
  final repo = ref.read(reportsRepositoryProvider);
  final range = ref.watch(productDateRangeProvider);
  return repo.getProductsReport(from: range.from, to: range.to);
});

final appointmentsReportProvider =
    FutureProvider.autoDispose<AppointmentsReportData>((ref) async {
  final repo = ref.read(reportsRepositoryProvider);
  final range = ref.watch(appointmentDateRangeProvider);
  return repo.getAppointmentsReport(from: range.from, to: range.to);
});
