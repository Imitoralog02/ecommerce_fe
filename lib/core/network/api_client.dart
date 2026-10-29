import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

abstract interface class SessionStorage {
  Future<String?> readRefresh();
  Future<void> writeRefresh(String? token);
}

class SecureSessionStorage implements SessionStorage {
  const SecureSessionStorage();
  static const _key = 'neora_refresh_token';
  static const _storage = FlutterSecureStorage();
  @override
  Future<String?> readRefresh() => _storage.read(key: _key);
  @override
  Future<void> writeRefresh(String? token) async {
    if (token == null) {
      await _storage.delete(key: _key);
    } else {
      await _storage.write(key: _key, value: token);
    }
  }
}

class ApiException implements Exception {
  const ApiException(this.status, this.message, [this.code]);
  final int status;
  final String message;
  final String? code;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    http.Client? client,
    SessionStorage? storage,
    String? baseUrl,
    this.requestTimeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client(),
       _storage = storage ?? const SecureSessionStorage(),
       baseUrl =
           baseUrl ??
           const String.fromEnvironment(
             'API_BASE_URL',
             defaultValue: 'http://10.0.2.2:8080/api/v1',
           );

  final http.Client _client;
  final SessionStorage _storage;
  final String baseUrl;
  final Duration requestTimeout;
  String? _accessToken;
  String? _refreshToken;
  Future<void>? _refreshing;
  String? userId;
  bool get isAuthenticated => _accessToken != null;

  Future<void> restoreSession() async {
    _refreshToken = await _storage.readRefresh();
    if (_refreshToken == null) return;
    try {
      await _refresh();
    } on ApiException catch (error) {
      if (error.status == 400 || error.status == 401) await clearSession();
    } catch (_) {
      // Keep the refresh token when the gateway is temporarily unreachable.
    }
  }

  Future<void> authenticate(String route, Map<String, Object?> body) async {
    final result = await _send('POST', route, body: body, auth: false);
    await _acceptTokens(result as Map<String, dynamic>);
  }

  Future<void> logout() async {
    final token = _refreshToken;
    try {
      if (token != null) {
        await _send(
          'POST',
          '/auth/logout',
          body: {'refreshToken': token},
          auth: false,
        );
      }
    } finally {
      await clearSession();
    }
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    userId = null;
    await _storage.writeRefresh(null);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);
  Future<dynamic> post(
    String path,
    Map<String, Object?> body, {
    Map<String, String>? headers,
  }) => _send('POST', path, body: body, headers: headers);
  Future<dynamic> put(String path, Map<String, Object?> body) =>
      _send('PUT', path, body: body);
  Future<dynamic> patch(String path) => _send('PATCH', path);
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<void> _acceptTokens(Map<String, dynamic> result) async {
    _accessToken = result['accessToken'] as String;
    _refreshToken = result['refreshToken'] as String;
    userId = (result['user'] as Map<String, dynamic>)['id'] as String;
    await _storage.writeRefresh(_refreshToken);
  }

  Future<void> _refresh() async {
    final token = _refreshToken;
    if (token == null) {
      throw const ApiException(401, 'Phiên đăng nhập đã hết hạn');
    }
    final result = await _send(
      'POST',
      '/auth/refresh',
      body: {'refreshToken': token},
      auth: false,
    );
    await _acceptTokens(result as Map<String, dynamic>);
  }

  Future<void> _refreshOnce() {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight;
    final future = _refresh();
    _refreshing = future;
    return future.whenComplete(() => _refreshing = null);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
    Map<String, String>? query,
    Map<String, String>? headers,
    bool auth = true,
    bool retry = true,
  }) async {
    final uri = Uri.parse(
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$path',
    ).replace(queryParameters: query);
    final request = http.Request(method, uri);
    request.headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    if (auth && _accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    if (headers != null) request.headers.addAll(headers);
    late final http.Response response;
    try {
      response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(requestTimeout);
    } on http.ClientException {
      throw const ApiException(
        503,
        'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng và thử lại.',
      );
    } on TimeoutException {
      throw const ApiException(503, 'Kết nối quá lâu. Vui lòng thử lại.');
    }
    if (response.statusCode == 401 && auth && retry && _refreshToken != null) {
      try {
        await _refreshOnce();
        return _send(
          method,
          path,
          body: body,
          query: query,
          headers: headers,
          auth: auth,
          retry: false,
        );
      } on ApiException catch (error) {
        if (error.status == 400 || error.status == 401) await clearSession();
        rethrow;
      }
    }
    final dynamic decoded = response.body.isEmpty
        ? null
        : jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded is Map<String, dynamic>
          ? decoded
          : const <String, dynamic>{};
      throw ApiException(
        response.statusCode,
        (error['message'] as String?) ??
            'Yêu cầu thất bại (${response.statusCode})',
        error['code'] as String?,
      );
    }
    return decoded;
  }
}
