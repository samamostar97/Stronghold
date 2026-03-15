import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/audit_logs_repository.dart';
import '../models/audit_log_response.dart';

final auditLogsRepositoryProvider = Provider((ref) => AuditLogsRepository());

class AuditLogsFilter {
  final int pageNumber;
  final String? search;
  final String? entityTypeFilter;

  const AuditLogsFilter({
    this.pageNumber = 1,
    this.search,
    this.entityTypeFilter,
  });

  AuditLogsFilter copyWith({
    int? pageNumber,
    String? search,
    String? entityTypeFilter,
    bool clearEntityTypeFilter = false,
  }) {
    return AuditLogsFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      search: search ?? this.search,
      entityTypeFilter: clearEntityTypeFilter
          ? null
          : (entityTypeFilter ?? this.entityTypeFilter),
    );
  }
}

class AuditLogsFilterNotifier extends Notifier<AuditLogsFilter> {
  @override
  AuditLogsFilter build() => const AuditLogsFilter();

  void update(AuditLogsFilter filter) => state = filter;
}

final auditLogsFilterProvider =
    NotifierProvider<AuditLogsFilterNotifier, AuditLogsFilter>(
        AuditLogsFilterNotifier.new);

final auditLogsProvider =
    FutureProvider.autoDispose<PagedAuditLogResponse>((ref) async {
  final repo = ref.read(auditLogsRepositoryProvider);
  final filter = ref.watch(auditLogsFilterProvider);

  return repo.getAuditLogs(
    pageNumber: filter.pageNumber,
    pageSize: 10,
    search: filter.search,
    entityType: filter.entityTypeFilter,
    orderDescending: true,
  );
});
