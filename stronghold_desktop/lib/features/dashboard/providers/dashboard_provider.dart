import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());

final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getStats();
});

final dashboardActivityProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getActivity();
});
