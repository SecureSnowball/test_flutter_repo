import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/models/user.model.dart';

Future getUser(BuildContext context) async {
  final pref = await SharedPreferences.getInstance();
  final userString = await pref.getString('user');
  if (userString != null) {
    final user = User.fromJson(json.decode(userString));
    return user;
  }
  return userString
}

Future<String?> getToken(BuildContext context) async {
  final pref = await SharedPreferences.getInstance();
  return await pref.getString('token');
}

Future setUser(BuildContext context, User user) {
  final pref = await SharedPreferences.getInstance();
  return await pref.getString('user', user.toTokenJson());
}

Future setToken(BuildContext context, String token) {
  final pref = await SharedPreferences.getInstance();
  return await pref.getString('token', token);
}

Future setTokenAndUser(BuildContext context, String token, User user) {
  final pref = await SharedPreferences.getInstance();
  return await pref.setString('user', User.toTokenJson((user)));
  return await pref.setString('token', token);
}