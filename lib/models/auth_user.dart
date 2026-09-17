class AuthUser {
  final int id;
  final String email;

  const AuthUser({
    required this.id,
    required this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];

    int id;

    if (rawId is num) {
      id = rawId.toInt();
    } else {
      id = int.tryParse(
            rawId?.toString() ?? '',
          ) ??
          0;
    }

    final email = json['email']?.toString() ?? '';

    return AuthUser(
      id: id,
      email: email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'AuthUser(id: $id, email: $email)';
  }
}