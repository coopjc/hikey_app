import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../config/api_config.dart';
import '../models/auth_session.dart';
import '../models/user.dart';
import 'token_storage.dart';

class AuthService {
  AuthService({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _api = apiClient,
       _tokens = tokenStorage;

  final ApiClient _api;
  final TokenStorage _tokens;

  Future<AuthSession> register({
    required String displayName,
    required int age,
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> json = await _api.post(
      ApiConfig.registerPath,
      authenticated: false,
      body: <String, dynamic>{
        'display_name': displayName,
        'age': age,
        'email': email,
        'password': password,
      },
    );

    final Object? data = json['data'];
    final String? message = json['message'] as String?;

    // If the response does not contain data, there was an error.
    // Throw an exception with the message from the response.
    if (data == null || data is! Map<String, dynamic>) {
      if (message is String) {
        throw ApiException(message);
      }
    }

    return _createSession(json);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> json = await _api.post(
      ApiConfig.loginPath,
      authenticated: false,
      body: <String, dynamic>{'email': email, 'password': password},
    );

    final Object? data = json['data'];
    final String? message = json['message'] as String?;

    // If the response does not contain data, there was an error.
    // Throw an exception with the message from the response.
    if (data == null || data is! Map<String, dynamic>) {
      if (message is String) {
        throw ApiException(message);
      }
    }

    return _createSession(json);
  }

  Future<void> logout() => _tokens.clearToken();

  Future<User> fetchCurrentUser() async {
    final Map<String, dynamic> json = await _api.get(ApiConfig.currentUserPath);

    final Object? data = json['data'];
    final String? message = json['message'] as String?;
    final int? status = json['status'] as int?;

    // If the response does not contain data, there was an error.
    // Throw an exception with the message from the response.
    if (data == null || data is! Map<String, dynamic>) {
      if (message is String) {
        throw ApiException(message, statusCode: status);
      }
    }

    return User.fromJson(json);
  }

  Future<String?> readStoredToken() => _tokens.readToken();

  Future<AuthSession> _createSession(Map<String, dynamic> json) async {
    final AuthSession session = AuthSession.fromJson(json);
    await _tokens.saveToken(session.token);
    return session;
  }
}
