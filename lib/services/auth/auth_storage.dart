import 'package:hive/hive.dart';

class AuthStorage {
  final Box box;

  static const tokenKey =
      'auth_token';

  AuthStorage(
    this.box,
  );

  String? getToken() {
    final value =
        box.get(tokenKey);

    if (value is String &&
        value.isNotEmpty) {
      return value;
    }

    return null;
  }

  Future<void> saveToken(
    String token,
  ) async {
    await box.put(
      tokenKey,
      token,
    );
  }

  Future<void> clearToken() async {
    await box.delete(
      tokenKey,
    );
  }
}