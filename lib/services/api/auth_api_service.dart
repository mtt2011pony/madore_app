import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/auth_user.dart';
import '../../models/user_session.dart';

class AuthApiService {
  final String baseUrl;

  final http.Client _client;




  AuthApiService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client();

  /// 登录
  ///
  /// Backend:
  ///
  /// POST /api/auth/login
  ///
  /// Request:
  /// {
  ///   "email": "...",
  ///   "password": "..."
  /// }
  ///
  /// Response:
  /// {
  ///   "token": "...",
  ///   "user": {
  ///     "id": 2,
  ///     "email": "..."
  ///   }
  /// }
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/api/auth/login'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    _checkResponse(response);

    final data = _decodeObject(response);

    return UserSession.fromJson(data);
  }

  /// 注册
  ///
  /// Backend:
  /// POST /api/auth/register
  Future<UserSession> register({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();

    final response = await _client.post(
      _uri('/api/auth/register'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'email': normalizedEmail,
        'password': password,
      }),
    );

    _checkResponse(response);

    final data = _decodeObject(response);

    // 如果注册接口本身就返回 token，
    // 直接使用注册接口返回的 session。
    try {
      return UserSession.fromJson(data);
    } on FormatException {
      // 注册成功但没有返回 token。
      // 这种情况下继续走正常登录流程获取 token。
      return login(
        email: normalizedEmail,
        password: password,
      );
    }
  }

  /// 获取当前登录用户
  ///
  /// Backend:
  /// GET /api/auth/me
  Future<AuthUser> getMe({
    required String token,
  }) async {
    final response = await _client.get(
      _uri('/api/auth/me'),
      headers: _authHeaders(token),
    );

    _checkResponse(response);

    final data = _decodeObject(response);

    final userJson = data['user'];

    if (userJson is Map) {
      return AuthUser.fromJson(
        Map<String, dynamic>.from(userJson),
      );
    }

    return AuthUser.fromJson(data);
  }

  /// 登出
  ///
  /// Backend:
  /// POST /api/auth/logout
  Future<void> logout({
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/auth/logout'),
      headers: _authHeaders(token),
    );

    _checkResponse(response);
  }

  Uri _uri(String path) {
    final normalizedBase =
        baseUrl.endsWith('/')
            ? baseUrl.substring(
                0,
                baseUrl.length - 1,
              )
            : baseUrl;

    return Uri.parse(
      '$normalizedBase$path',
    );
  }

  Map<String, String> _jsonHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Map<String, String> _authHeaders(
    String token,
  ) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeObject(
    http.Response response,
  ) {
    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded =
        jsonDecode(response.body);

    if (decoded is! Map) {
      throw const FormatException(
        '服务器返回的数据格式错误',
      );
    }

    return Map<String, dynamic>.from(
      decoded,
    );
  }

  void _checkResponse(
    http.Response response,
  ) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    String message = '请求失败';

    try {
      final decoded =
          jsonDecode(response.body);

      if (decoded is Map &&
          decoded['message'] != null) {
        message =
            decoded['message'].toString();
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }

    throw AuthApiException(
      statusCode: response.statusCode,
      message: message,
    );
  }

  void dispose() {
    _client.close();
  }
}

class AuthApiException implements Exception {
  final int statusCode;
  final String message;

  const AuthApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() {
    return 'AuthApiException('
        '$statusCode, $message'
        ')';
  }
}