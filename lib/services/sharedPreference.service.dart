import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/models/user.model.dart';

Future getUser(BuildContext context) async {
  final pref = await SharedPreferences.getInstance();
  final userString = pref.getString('user');
  if (userString != null) {
    final user = User.fromJson(json.decode(userString));
    return user;
  }
  return userString;
}

Future<String?> getToken(BuildContext context) async {
  final pref = await SharedPreferences.getInstance();
  return pref.getString('token');
}

Future setUser(BuildContext context, User user) async {
  final pref = await SharedPreferences.getInstance();
  return await pref.setString('user', json.encode(user.toTokenJson()));
}

Future setToken(BuildContext context, String token) async {
  final pref = await SharedPreferences.getInstance();
  return await pref.setString('token', token);
}

Future setTokenAndUser(BuildContext context, String token, User user) async {
  final pref = await SharedPreferences.getInstance();
  return await Future.wait([
    pref.setString('user', json.encode(user.toTokenJson())),
    pref.setString('token', token),
  ]);
}
