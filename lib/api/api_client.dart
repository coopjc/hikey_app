import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({required TokenStorage tokenStorage, http.Client? httpClient})
    : _tokens = tokenStorage,
      _http = httpClient ?? http.Client();

  final TokenStorage _tokens;
  final http.Client _http;

  final String _baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool authenticated = true,
  }) {
    return _send('GET', path, query: query, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    Map<String, String>? query,
    bool authenticated = true,
  }) {
    return _send(
      'POST',
      path,
      body: body,
      query: query,
      authenticated: authenticated,
    );
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
    bool authenticated = true,
  }) {
    return _send('PATCH', path, body: body, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Object? body,
    bool authenticated = true,
  }) {
    return _send('DELETE', path, body: body, authenticated: authenticated);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool authenticated = true,
  }) async {
    final Uri uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: (query == null || query.isEmpty) ? null : query);

    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };

    if (authenticated) {
      final String? token = await _tokens.readToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final http.Request request = http.Request(method, uri)
      ..headers.addAll(headers);

    if (body != null) request.body = jsonEncode(body);

    late final http.Response response;

    try {
      final http.StreamedResponse streamed = await _http
          .send(request)
          .timeout(ApiConfig.timeout);

      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException(
        'The request timed out. Check your connection and try again.',
      );
    } on SocketException {
      throw ApiException(
        "Can't reach the Hikey server. Check your connection and try again.",
      );
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    }

    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final String body = response.body;

    try {
      return jsonDecode(body);
    } on FormatException {
      throw ApiException('Invalid JSON response from the server.');
    }
  }
}
