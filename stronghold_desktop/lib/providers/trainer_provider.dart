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
final trainerListProvider = StateNotifierProvider<
    TrainerListNotifier,
    ListState<TrainerResponse, TrainerQueryFilter>>((ref) {
  final service = ref.watch(trainerServiceProvider);
  return TrainerListNotifier(service);
});

/// Trainer list notifier implementation
class TrainerListNotifier extends ListNotifier<
    TrainerResponse,
    CreateTrainerRequest,
    UpdateTrainerRequest,
    TrainerQueryFilter> {
  TrainerListNotifier(TrainerService service)
      : super(
          service: service,
          initialFilter: TrainerQueryFilter(),
        );
  @override
  TrainerQueryFilter createFilterCopy({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    // null = keep old value, '' = clear search, 'value' = new search
    final searchValue = search == null ? state.filter.search : (search.isEmpty ? null : search);
    return TrainerQueryFilter(
      pageNumber: pageNumber ?? state.filter.pageNumber,
      pageSize: pageSize ?? state.filter.pageSize,
      search: searchValue,
      orderBy: orderBy ?? state.filter.orderBy,
    );
  }
}
