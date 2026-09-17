import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../config/api_config.dart';
import 'package:http/http.dart' as http;

import '../auth/auth_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() {
    return message;
  }
}

class ApiClient {
  final http.Client client;
  final AuthStorage authStorage;

  ApiClient({
    required this.authStorage,
    http.Client? client,
  }) : client =
            client ?? http.Client();




  Uri buildUri(
    String path,
  ) {

    final baseUrl = ApiConfig.baseUrl;
    if (baseUrl.isEmpty) {
      // Web production
      return Uri.base.resolve(path);
    }

    return Uri.parse(
      '$baseUrl$path',
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    bool authenticated = true,
  }) async {
    final response =
        await client.get(
      buildUri(path),
      headers:
          await _headers(
        authenticated:
            authenticated,
      ),
    );

    return _parseResponse(
      response,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final response =
        await client.post(
      buildUri(path),
      headers:
          await _headers(
        authenticated:
            authenticated,
      ),
      body: body == null
          ? null
          : jsonEncode(body),
    );

    return _parseResponse(
      response,
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final response =
        await client.put(
      buildUri(path),
      headers:
          await _headers(
        authenticated:
            authenticated,
      ),
      body: body == null
          ? null
          : jsonEncode(body),
    );

    return _parseResponse(
      response,
    );
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool authenticated = true,
  }) async {
    final response =
        await client.delete(
      buildUri(path),
      headers:
          await _headers(
        authenticated:
            authenticated,
      ),
    );

    return _parseResponse(
      response,
    );
  }

  Future<Map<String, String>>
      _headers({
    required bool authenticated,
  }) async {
    final headers =
        <String, String>{
      'Content-Type':
          'application/json',
      'Accept':
          'application/json',
    };

    if (authenticated) {
      final token =
          authStorage.getToken();

      if (token != null &&
          token.isNotEmpty) {
        headers['Authorization'] =
            'Bearer $token';
      }
    }

    return headers;
  }

  Map<String, dynamic> _parseResponse(
    http.Response response,
  ) {
    final body =
        response.body;

    Map<String, dynamic> data;

    try {
      final decoded =
          jsonDecode(body);

      if (decoded
          is Map<String, dynamic>) {
        data = decoded;
      } else {
        throw const FormatException(
          'Response is not a JSON object',
        );
      }
    } catch (_) {
      throw ApiException(
        statusCode:
            response.statusCode,
        message:
            'Server returned invalid JSON: '
            '${response.statusCode}',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw ApiException(
        statusCode:
            response.statusCode,
        message:
            data['message']
                    ?.toString() ??
                'Request failed: '
                    '${response.statusCode}',
      );
    }

    return data;
  }

  void dispose() {
    client.close();
  }
}