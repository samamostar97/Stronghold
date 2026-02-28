import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';
import 'list_notifier.dart';
import 'list_state.dart';

/// Trainer service provider
final trainerServiceProvider = Provider<TrainerService>((ref) {
  return TrainerService(ref.watch(apiClientProvider));
});

/// Trainer list state provider
final trainerListProvider =
    StateNotifierProvider<
      TrainerListNotifier,
      ListState<TrainerResponse, TrainerQueryFilter>
    >((ref) {
      final service = ref.watch(trainerServiceProvider);
      return TrainerListNotifier(service);
    });

/// Total trainer count (lightweight, fetches 1 item for totalCount).
final trainerCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(trainerServiceProvider);
  final result = await service.getAll(TrainerQueryFilter(pageSize: 1));
  return result.totalCount;
});

/// Trainer list notifier implementation
class TrainerListNotifier
    extends
        ListNotifier<
          TrainerResponse,
          CreateTrainerRequest,
          UpdateTrainerRequest,
          TrainerQueryFilter
        > {
  TrainerListNotifier(TrainerService service)
    : super(service: service, initialFilter: TrainerQueryFilter());
  @override
  TrainerQueryFilter createFilterCopy({
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
