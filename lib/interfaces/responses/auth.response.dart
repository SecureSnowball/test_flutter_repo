import 'package:test_app/models/user.model.dart';

class AuthResponse {
  final String? token;
  final User? user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> result) {
    return AuthResponse(
      token: result['token'],
      user: User.fromJson(result['user']),
    );
  }
}