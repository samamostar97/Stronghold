import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// Visit service provider
final visitServiceProvider = Provider<VisitService>((ref) {
  return VisitService(ref.watch(apiClientProvider));
});

/// Current visitors state
class CurrentVisitorsState {
  final List<CurrentVisitorResponse> visitors;
  final bool isLoading;
  final String? error;

  const CurrentVisitorsState({
    this.visitors = const [],
    this.isLoading = false,
    this.error,
  });

  CurrentVisitorsState copyWith({
    List<CurrentVisitorResponse>? visitors,
    bool? isLoading,
    String? error,
  }) {
    return CurrentVisitorsState(
      visitors: visitors ?? this.visitors,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Current visitors notifier
class CurrentVisitorsNotifier extends StateNotifier<CurrentVisitorsState> {
  final VisitService _service;

  CurrentVisitorsNotifier(this._service) : super(const CurrentVisitorsState());

  /// Load current visitors
  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final visitors = await _service.getCurrentVisitors();
      state = state.copyWith(visitors: visitors, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Check in a user
  Future<void> checkIn(int userId) async {
    await _service.checkIn(CheckInRequest(userId: userId));
    await load(); // Refresh the list
  }

  /// Check out a visitor
  Future<void> checkOut(int visitId) async {
    await _service.checkOut(visitId);
    await load(); // Refresh the list
  }

  /// Filter visitors by search query (client-side)
  List<CurrentVisitorResponse> filterVisitors(String query) {
    if (query.isEmpty) return state.visitors;
    final lowerQuery = query.toLowerCase().trim();
    return state.visitors.where((visitor) {
      return visitor.username.toLowerCase().contains(lowerQuery) ||
             visitor.firstName.toLowerCase().contains(lowerQuery) ||
             visitor.lastName.toLowerCase().contains(lowerQuery) ||
             visitor.fullName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

/// Current visitors provider
final currentVisitorsProvider = StateNotifierProvider<CurrentVisitorsNotifier, CurrentVisitorsState>((ref) {
  final service = ref.watch(visitServiceProvider);
  return CurrentVisitorsNotifier(service);
});
