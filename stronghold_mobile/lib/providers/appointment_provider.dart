import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../models/appointment_models.dart';
import 'api_providers.dart';

/// My appointments state
class MyAppointmentsState {
  final List<Appointment> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final bool isLoading;
  final String? error;

  const MyAppointmentsState({
    this.items = const [],
    this.totalCount = 0,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.isLoading = false,
    this.error,
  });

  MyAppointmentsState copyWith({
    List<Appointment>? items,
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
  final ApiClient _client;

  MyAppointmentsNotifier(this._client) : super(const MyAppointmentsState());

  /// Load user's appointments
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, String>{
        'pageNumber': state.pageNumber.toString(),
        'pageSize': state.pageSize.toString(),
      };

      final result = await _client.get<Map<String, dynamic>>(
        '/api/appointments/my',
        queryParameters: queryParams,
        parser: (json) => json as Map<String, dynamic>,
      );

      final itemsList = result['items'] as List<dynamic>;
      final appointments = itemsList
          .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        items: appointments,
        totalCount: result['totalCount'] as int,
        pageNumber: result['pageNumber'] as int,
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
      await _client.delete('/api/appointments/$id');
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
      final queryParams = <String, String>{
        'pageNumber': nextPageNumber.toString(),
        'pageSize': state.pageSize.toString(),
      };

      final result = await _client.get<Map<String, dynamic>>(
        '/api/appointments/my',
        queryParameters: queryParams,
        parser: (json) => json as Map<String, dynamic>,
      );

      final itemsList = result['items'] as List<dynamic>;
      final newAppointments = itemsList
          .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        items: [...state.items, ...newAppointments],
        totalCount: result['totalCount'] as int,
        pageNumber: result['pageNumber'] as int,
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
  return MyAppointmentsNotifier(client);
});

/// Trainers list provider
final trainersProvider = FutureProvider<List<Trainer>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final result = await client.get<Map<String, dynamic>>(
    '/api/trainer/GetAllPaged',
    queryParameters: {'pageSize': '100'},
    parser: (json) => json as Map<String, dynamic>,
  );
  final items = result['items'] as List<dynamic>;
  return items.map((j) => Trainer.fromJson(j as Map<String, dynamic>)).toList();
});

/// Nutritionists list provider
final nutritionistsProvider = FutureProvider<List<Nutritionist>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final result = await client.get<Map<String, dynamic>>(
    '/api/nutritionist/GetAllPaged',
    queryParameters: {'pageSize': '100'},
    parser: (json) => json as Map<String, dynamic>,
  );
  final items = result['items'] as List<dynamic>;
  return items.map((j) => Nutritionist.fromJson(j as Map<String, dynamic>)).toList();
});

/// Available hours for trainer
final trainerAvailableHoursProvider =
    FutureProvider.family<List<int>, ({int trainerId, DateTime date})>((ref, params) async {
  final client = ref.watch(apiClientProvider);
  return client.get<List<int>>(
    '/api/trainer/${params.trainerId}/available-hours',
    queryParameters: {'date': DateTimeUtils.toApiDate(params.date)},
    parser: (json) => (json as List<dynamic>).map((e) => e as int).toList(),
  );
});

/// Available hours for nutritionist
final nutritionistAvailableHoursProvider =
    FutureProvider.family<List<int>, ({int nutritionistId, DateTime date})>((ref, params) async {
  final client = ref.watch(apiClientProvider);
  return client.get<List<int>>(
    '/api/nutritionist/${params.nutritionistId}/available-hours',
    queryParameters: {
      'date': DateTimeUtils.toApiDate(params.date)
    },
    parser: (json) => (json as List<dynamic>).map((e) => e as int).toList(),
  );
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
  final ApiClient _client;

  BookAppointmentNotifier(this._client) : super(const BookAppointmentState());

  /// Book trainer appointment
  Future<void> bookTrainer(int trainerId, DateTime date) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _client.post<void>(
        '/api/trainer/$trainerId/appointments',
        body: {'date': DateTimeUtils.toApiDateTime(date)},
        parser: (_) {},
      );
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
      await _client.post<void>(
        '/api/nutritionist/$nutritionistId/appointments',
        body: {'date': DateTimeUtils.toApiDateTime(date)},
        parser: (_) {},
      );
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
  return BookAppointmentNotifier(client);
});
