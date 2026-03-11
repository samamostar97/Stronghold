class TokenStorage {
  static String? accessToken;
  static String? refreshToken;

  static void save(String access, String refresh) {
    accessToken = access;
    refreshToken = refresh;
  }

  static void clear() {
    accessToken = null;
    refreshToken = null;
  }

  static bool get isLoggedIn => accessToken != null;
}
