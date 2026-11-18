class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment('API_URL');
  static bool get isConfigured => baseUrl.isNotEmpty;

  static const String registerPath = '/api/auth/register';
  static const String loginPath = '/api/auth/login';
  static const String currentUserPath = '/api/users/me';
  static const String currentUserStatsPath = '/api/users/me/stats';
  static const String getHikesPath = '/api/hikes';
  static const String createHikePath = '/api/hikes';
  static String hikePath(int hikeId) => '/api/hikes/$hikeId';
  static String hikePointsPath(int hikeId) => '/api/hikes/$hikeId/points';
  static String pauseHikePath(int hikeId) => '/api/hikes/$hikeId/pause';
  static String resumeHikePath(int hikeId) => '/api/hikes/$hikeId/resume';
  static String completeHikePath(int hikeId) => '/api/hikes/$hikeId/complete';

  static const Duration timeout = Duration(seconds: 15);
}
