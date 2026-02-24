import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// User progress provider
final userProgressProvider = FutureProvider<UserProgressResponse>((ref) async {
  final client = ref.watch(apiClientProvider);
  return ProfileService(client).getProgress();
});

/// Leaderboard provider
final leaderboardProvider = FutureProvider<List<LeaderboardEntryResponse>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return ProfileService(client).getLeaderboard();
});

/// Membership history provider
final membershipHistoryProvider = FutureProvider<List<MembershipPaymentResponse>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return ProfileService(client).getMembershipHistory();
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
  final ProfileService _service;

  ProfilePictureNotifier(this._service) : super(const ProfilePictureState());

  /// Upload profile picture
  Future<String> upload(String filePath) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final url = await _service.uploadPicture(filePath);
      state = state.copyWith(isLoading: false);
      return url;
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
      await _service.deletePicture();
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
  return ProfilePictureNotifier(ProfileService(client));
});
