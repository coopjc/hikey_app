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

    // If the response does not contain data, there was an error.
    // Throw an exception with the message from the response.
    if (data == null || (data is! Map<String, dynamic> && data is! String)) {
      final Object? message = json['message'];

      throw ApiException(
        message is String && message.isNotEmpty
            ? message
            : 'Unexpected auth response from the server.',
        statusCode: json['status'] as int?,
      );
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

    // If the response does not contain data, there was an error.
    // Throw an exception with the message from the response.
    if (data == null || (data is! Map<String, dynamic> && data is! String)) {
      final Object? message = json['message'];

      if (message is String && message.isNotEmpty) {
        throw ApiException(message, statusCode: json['status'] as int?);
      }
    }

    return _createSession(json);
  }

  Future<void> logout() => _tokens.clearToken();

  Future<User> fetchCurrentUser() async {
    final Map<String, dynamic> json = await _api.get(ApiConfig.currentUserPath);

    final Object? data = json['data'];

    if (data is! Map<String, dynamic>) {
      final Object? message = json['message'];

      throw ApiException(
        message is String && message.isNotEmpty
            ? message
            : 'Unexpected current user response from the server.',
        statusCode: json['status'] as int?,
      );
    }

    return User.fromJson(data);
  }

  Future<String?> readStoredToken() => _tokens.readToken();

  Future<AuthSession> _createSession(Map<String, dynamic> json) async {
    final AuthSession session = AuthSession.fromJson(json);
    await _tokens.saveToken(session.token);
    return session;
  }
}
