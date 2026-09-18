class AuthSession {
  const AuthSession({required this.token, this.message});

  final String token;
  final String? message;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final Object? data = json['data'];
    final String? message = json['message'];

    if (data is String) {
      if (data.isEmpty) {
        throw const FormatException('Auth response did not contain a token.');
      }

      return AuthSession(token: data, message: message);
    }

    if (data is Map<String, dynamic>) {
      final Object token = data['token'];

      if (token is! String || token.isEmpty) {
        throw const FormatException('Auth response did not contain a token.');
      }

      return AuthSession(token: token, message: message);
    }

    throw const FormatException(
      'Auth response did not contain a data payload.',
    );
  }
}
