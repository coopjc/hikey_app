import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import '../models/auth_session.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { authenticated, unauthenticated, unknown }

class AuthController extends ChangeNotifier {
  AuthController({required AuthService authService}) : _auth = authService;

  final AuthService _auth;

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  String? _message;

  bool get isLoading => _isLoading;
  String? get message => _message;

  Future<void> loadSession() async {
    final String? token = await _auth.readStoredToken();

    if (token == null || token.isEmpty) {
      _setStatus(AuthStatus.unauthenticated);
      return;
    }

    try {
      _user = await _auth.fetchCurrentUser();
      _setStatus(AuthStatus.authenticated);
    } on ApiException catch (e) {
      if (e.isNetworkError) {
        _setStatus(AuthStatus.authenticated);
      } else {
        await _auth.logout();
        _setStatus(AuthStatus.unauthenticated);
      }
    }
  }

  Future<bool> register({
    required String displayName,
    required int age,
    required String email,
    required String password,
  }) {
    return _handleAuthMethod(
      () => _auth.register(
        displayName: displayName.trim(),
        age: age,
        email: email.trim(),
        password: password,
      ),
    );
  }

  Future<bool> login({required String email, required String password}) {
    return _handleAuthMethod(
      () => _auth.login(email: email.trim(), password: password),
    );
  }

  Future<void> logout() async {
    await _auth.logout();

    _user = null;
    _message = null;

    _setStatus(AuthStatus.unauthenticated);
  }

  Future<bool> _handleAuthMethod(
    Future<AuthSession> Function() authMethod,
  ) async {
    if (_isLoading) return false;

    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      final AuthSession session = await authMethod();

      _user = await _fetchCurrentUser();

      _message = session.message;
      _isLoading = false;

      _setStatus(AuthStatus.authenticated);
      return true;
    } on ApiException catch (e) {
      if (e.isNetworkError) {
        _message = 'Please check your network and try again later.';
      } else {
        _message = e.message;
      }

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> _fetchCurrentUser() async {
    try {
      return await _auth.fetchCurrentUser();
    } on ApiException {
      return null;
    }
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void clearMessage() {
    if (_message == null) return;

    _message = null;

    notifyListeners();
  }
}
