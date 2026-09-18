import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _tokenKey = 'auth_token';

  String? _storedToken;
  String? get storedToken => _storedToken;

  Future<String?> readToken() async {
    _storedToken ??= await _storage.read(key: _tokenKey);
    return _storedToken;
  }

  Future<void> saveToken(String token) async {
    _storedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    _storedToken = null;
    await _storage.delete(key: _tokenKey);
  }
}
