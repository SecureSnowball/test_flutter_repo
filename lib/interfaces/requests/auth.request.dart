import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:test_app/models/user.model.dart';
import 'package:test_app/config/constants.dart';
import 'package:test_app/exceptions/unknown.exception.dart';
import 'package:test_app/interfaces/responses/auth.response.dart';
import 'package:test_app/services/http.service.dart' as http_service;

Future<AuthResponse> login({
  required final String email,
  required final String password,
  required final BuildContext context,
}) async {
  final response = await http_service.post(
    url: baseUrl + '/api/auth/login',
    context: context,
    body: {
      'email': email,
      'password': password,
    },
  );
  if (response!.statusCode != 200) throw UnknownException();

  return AuthResponse.fromJson(json.decode(response.body));
}

Future<AuthResponse> register({
  required final String name,
  required final String email,
  required final String password,
  required final BuildContext context,
}) async {
  const url = baseUrl + '/api/auth/register';
  final response = await http_service.post(
    url: url,
    context: context,
    body: {
      'name': name,
      'email': email,
      'password': password,
    },
  );
  if (response!.statusCode != 200) throw UnknownException();
  return AuthResponse.fromJson(json.decode(response.body));
}

Future<User> me({required BuildContext context}) async {
  final response = await http_service.authorizedGet(
    url: baseUrl + '/api/user/me',
    context: context,
  );
  if (response!.statusCode != 200) throw UnknownException();
  return User.fromJson(json.decode(response.body));
}