import 'package:test_app/interfaces/responses/auth.response.dart';
import 'package:test_app/models/user.model.dart';
import 'package:flutter/foundation.dart';

class AuthState extends ChangeNotifier {
  String? token;
  User? user;

  loadState(AuthResponse response) {
    token = response.token;
    user = response.user;
    notifyListeners();
  }

  clearState() {
    token = null;
    user = null;
    notifyListeners();
  }

  updateToken(String token) {
    this.token = token;
    notifyListeners();
  }

  updateUser(User user) {
    this.user = user;
    notifyListeners();
  }
}