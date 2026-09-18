class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment('API_URL');

  static const String registerPath = '/api/auth/register';
  static const String loginPath = '/api/auth/login';
  static const String currentUserPath = '/api/users/me';
  static const String getHikesPath = '/api/hikes';
  static const String createHikePath = '/api/hikes';
  static String hikePath(int hikeId) => '/api/hikes/$hikeId';
  static String hikePointsPath(int hikeId) => '/api/hikes/$hikeId/points';

  static const Duration timeout = Duration(seconds: 15);
}
