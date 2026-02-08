import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../models/progress_models.dart';
import '../models/membership_models.dart';
import 'api_providers.dart';

/// User progress provider
final userProgressProvider = FutureProvider<UserProgress>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.get<UserProgress>(
    '/api/profile/progress',
    parser: (json) => UserProgress.fromJson(json as Map<String, dynamic>),
  );
});

/// Leaderboard provider
final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.get<List<LeaderboardEntry>>(
    '/api/profile/leaderboard',
    parser: (json) => (json as List<dynamic>)
        .map((j) => LeaderboardEntry.fromJson(j as Map<String, dynamic>))
        .toList(),
  );
});

/// Membership history provider
final membershipHistoryProvider = FutureProvider<List<MembershipPayment>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.get<List<MembershipPayment>>(
    '/api/profile/membership-history',
    parser: (json) => (json as List<dynamic>)
        .map((j) => MembershipPayment.fromJson(j as Map<String, dynamic>))
        .toList(),
  );
});

/// Profile picture upload state
class ProfilePictureState {
  final bool isLoading;
  final String? error;

  const ProfilePictureState({this.isLoading = false, this.error});

  ProfilePictureState copyWith({bool? isLoading, String? error, bool clearError = false}) {
    return ProfilePictureState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Profile picture notifier
class ProfilePictureNotifier extends StateNotifier<ProfilePictureState> {
  final ApiClient _client;

  ProfilePictureNotifier(this._client) : super(const ProfilePictureState());

  /// Upload profile picture
  Future<String> upload(String filePath) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _client.uploadFile<String>(
        '/api/profile/picture',
        filePath,
        'file',
        parser: (json) => json as String,
      );
      state = state.copyWith(isLoading: false);
      return result;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom uploada slike',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Delete profile picture
  Future<void> delete() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _client.delete('/api/profile/picture');
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(
        error: 'Greska prilikom brisanja slike',
        isLoading: false,
      );
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Profile picture provider
final profilePictureProvider =
    StateNotifierProvider<ProfilePictureNotifier, ProfilePictureState>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProfilePictureNotifier(client);
});
