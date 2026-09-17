import 'auth_user.dart';

class UserSession {
  final String token;
  final AuthUser user;

  const UserSession({
    required this.token,
    required this.user,
  });

  int get userId => user.id;

  String get email => user.email;

  factory UserSession.fromJson(Map<String, dynamic> json) {
    // 兼容后端：
    // {
    //   "success": true,
    //   "data": {
    //     "token": "...",
    //     "user": {...}
    //   }
    // }
    //
    // 同时兼容原来的：
    // {
    //   "token": "...",
    //   "user": {...}
    // }

    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'])
        : json;

    final token = data['token']?.toString();

    if (token == null || token.isEmpty) {
      throw const FormatException('登录响应缺少 token');
    }

    final userJson = data['user'];

    if (userJson is! Map) {
      throw FormatException(
        '登录响应缺少 user：$json',
      );
    }

    return UserSession(
      token: token,
      user: AuthUser.fromJson(
        Map<String, dynamic>.from(userJson),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}