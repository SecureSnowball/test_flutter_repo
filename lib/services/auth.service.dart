import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:test_app/state/auth.state.dart';
import 'package:test_app/models/user.model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/interfaces/responses/auth.response.dart';
import 'package:test_app/interfaces/requests/auth.request.dart' as auth_request;

Future loadAuthState(BuildContext context) async {
  final authState = Provider.of<AuthState>(context, listen: false);
  authState.loadState(await _loadAuthPrefs());
  if (authState.token != null) await hydrateUser(context);
}

Future hydrateUser(BuildContext context) async {
  var user = await auth_request.me(context: context);
  await saveUser(user);
  Provider.of<AuthState>(context, listen: false)
      .loadState(await _loadAuthPrefs());
}

Future _saveAuthPrefs(AuthResponse response) async {
  final user = response.user;
  final token = response.token;
  final pref = await SharedPreferences.getInstance();
  await pref.setString('token', token!);
  await saveUser(user!, pref: pref);
}

Future saveUser(final User user, {SharedPreferences? pref}) async {
  pref ??= await SharedPreferences.getInstance();
  await Future.wait([
    pref.setInt('id', user.id!),
    pref.setString('name', user.name),
    pref.setString('email', user.email ?? ""),
    pref.setString('mobile', user.mobile ?? ""),
    pref.setBool('emailVerified', user.emailVerified!),
  ]);
}

Future _clearAuthPrefs() async {
  final pref = await SharedPreferences.getInstance();
  await pref.clear();
}

Future<AuthResponse> _loadAuthPrefs() async {
  final pref = await SharedPreferences.getInstance();
  final String? token = pref.getString('token');
  if (token == null) {
    return AuthResponse(token: null, user: null);
  }

  final id = pref.getInt('id');
  final name = pref.getString('name')!;
  final email = pref.getString('email')!;
  final emailVerified = pref.getBool('emailVerified');
  final user = User(
    id: id,
    name: name,
    email: email,
    emailVerified: emailVerified,
  );
  return AuthResponse(token: token, user: user);
}

Future register({
  required final String email,
  required final String name,
  required final String password,
  required final BuildContext context,
}) async {
  final result = await auth_request.register(
    email: email,
    password: password,
    name: name,
    context: context,
  );

  await _saveAuthPrefs(result);
  Provider.of<AuthState>(context, listen: false).loadState(result);
}

Future login({
  required final String email,
  required final String password,
  required final BuildContext context,
}) async {
  final result = await auth_request.login(
    context: context,
    email: email,
    password: password,
  );

  await _saveAuthPrefs(result);
  Provider.of<AuthState>(context, listen: false).loadState(result);
}

Future logout({required BuildContext context}) async {
  final authState = Provider.of<AuthState>(context, listen: false);
  if (authState.user == null) return;

  // await ProfileService.logout(
  //   context: context,
  //   payload: {},
  // );
  await _clearAuthPrefs();
  Provider.of<AuthState>(context, listen: false).clearState();
}