import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// My appointments state
class MyAppointmentsState {
  final List<UserAppointmentResponse> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final bool isLoading;
  final String? error;

  const MyAppointmentsState({
    this.items = const <UserAppointmentResponse>[],
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.isLoading = false,
    this.error,
  });

  MyAppointmentsState copyWith({
    List<UserAppointmentResponse>? items,
    int? totalCount,
    int? pageNumber,
    int? pageSize,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MyAppointmentsState(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasNextPage => pageNumber < totalPages;
}

/// My appointments notifier
class MyAppointmentsNotifier extends StateNotifier<MyAppointmentsState> {
  final UserAppointmentService _service;

  MyAppointmentsNotifier(this._service) : super(const MyAppointmentsState());

  /// Load user's appointments
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _service.getMyAppointments(
        pageNumber: state.pageNumber,
        pageSize: state.pageSize,
      );

      state = state.copyWith(
        items: result.items,
        totalCount: result.totalCount,
        pageNumber: result.pageNumber,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom ucitavanja termina',
        isLoading: false,
      );
    }
  }

  /// Cancel appointment
  Future<void> cancel(int id) async {
    try {
      await _service.cancel(id);
      await load(); // Refresh list
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      rethrow;
    }
  }

  /// Go to next page (appends items for infinite scroll)
  Future<void> nextPage() async {
    if (!state.hasNextPage || state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final nextPageNumber = state.pageNumber + 1;
      final result = await _service.getMyAppointments(
        pageNumber: nextPageNumber,
        pageSize: state.pageSize,
      );

      state = state.copyWith(
        items: [...state.items, ...result.items],
        totalCount: result.totalCount,
        pageNumber: result.pageNumber,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom ucitavanja termina',
        isLoading: false,
      );
    }
  }

  /// Refresh (resets to page 1)
  Future<void> refresh() async {
    state = state.copyWith(pageNumber: 1);
    await load();
  }
}

/// My appointments provider
final myAppointmentsProvider =
    StateNotifierProvider<MyAppointmentsNotifier, MyAppointmentsState>((ref) {
  final client = ref.watch(apiClientProvider);
  return MyAppointmentsNotifier(UserAppointmentService(client));
});

/// Trainers list provider
final trainersProvider = FutureProvider<List<TrainerResponse>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final filter = TrainerQueryFilter()..pageSize = 100;
  final result = await TrainerService(client).getAll(filter);
  return result.items;
});

/// Nutritionists list provider
final nutritionistsProvider = FutureProvider<List<NutritionistResponse>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final filter = NutritionistQueryFilter()..pageSize = 100;
  final result = await NutritionistService(client).getAll(filter);
  return result.items;
});

/// Available hours for trainer
final trainerAvailableHoursProvider =
    FutureProvider.family<List<int>, ({int trainerId, DateTime date})>((ref, params) async {
  final client = ref.watch(apiClientProvider);
  return TrainerService(client).getAvailableHours(params.trainerId, params.date);
});

/// Available hours for nutritionist
final nutritionistAvailableHoursProvider =
    FutureProvider.family<List<int>, ({int nutritionistId, DateTime date})>((ref, params) async {
  final client = ref.watch(apiClientProvider);
  return NutritionistService(client).getAvailableHours(params.nutritionistId, params.date);
});

/// Book appointment state
class BookAppointmentState {
  final bool isLoading;
  final String? error;

  const BookAppointmentState({this.isLoading = false, this.error});

  BookAppointmentState copyWith({bool? isLoading, String? error, bool clearError = false}) {
    return BookAppointmentState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Book appointment notifier
class BookAppointmentNotifier extends StateNotifier<BookAppointmentState> {
  final UserAppointmentService _service;

  BookAppointmentNotifier(this._service) : super(const BookAppointmentState());

  /// Book trainer appointment
  Future<void> bookTrainer(int trainerId, DateTime date) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.bookTrainer(trainerId, date);
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom zakazivanja termina',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Book nutritionist appointment
  Future<void> bookNutritionist(int nutritionistId, DateTime date) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.bookNutritionist(nutritionistId, date);
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom zakazivanja termina',
        isLoading: false,
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Book appointment provider
final bookAppointmentProvider =
    StateNotifierProvider<BookAppointmentNotifier, BookAppointmentState>((ref) {
  final client = ref.watch(apiClientProvider);
  return BookAppointmentNotifier(UserAppointmentService(client));
});
