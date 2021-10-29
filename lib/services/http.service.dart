import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/state/auth.state.dart';
import 'package:test_app/exceptions/auth.exception.dart';
import 'package:test_app/exceptions/server.exception.dart';
import 'package:test_app/exceptions/validation.exception.dart';
import 'package:test_app/services/auth.service.dart' as auth_service;

Future checkExceptions({
  required final http.Response response,
  required final BuildContext context,
}) async {
  if (response.statusCode == 422) {
    final responseBody = json.decode(response.body);
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Input Error'),
        content: Text('Please check your input'),
      ),
    );
    throw ValidationException(errors: responseBody['errors']);
  }

  if (response.statusCode == 413) {
    throw InternalServerErrorException(message: 'File(s) too big');
  }

  if (response.statusCode == 401) {
    await auth_service.logout(context: context);
    throw AuthException();
  }
  if (response.statusCode >= 500) throw InternalServerErrorException();
}

String? _getString(final dynamic value) {
  if (value == null || value == "") return null;
  if (value is String) return value;
  if (value is int || value is double) return "$value";
  return value as String;
}

Map<String, String> _flattenMap(Map map, {String? prefix}) {
  final Map<String, String> result = {};
  map.forEach((k, v) {
    if (v is List) {
      result.addAll(_flattenMapList(v, k, prefix: prefix));
    } else if (v is Map) {
      result.addAll(
        _flattenMap(
          v,
          prefix: prefix == null ? k : "$prefix[$k]",
        ),
      );
    } else {
      final value = _getString(v);
      if (value != null) {
        result[prefix == null ? k : "$prefix[$k]"] = value;
      }
    }
  });
  return result;
}

Map<String, String> _flattenMapList(
  final List list,
  final String key, {
  required final String? prefix,
}) {
  final Map<String, String> result = {};
  for (int i = 0; i < list.length; i++) {
    if (list[i] is Map) {
      result.addAll(
        _flattenMap(
          list[i],
          prefix: prefix == null ? "$key[$i]" : "$prefix[$key][$i]",
        ),
      );
    } else if (list[i] is List) {
      result.addAll(
        _flattenMapList(
          list[i],
          "$i",
          prefix: prefix == null ? key : "$prefix[$key]",
        ),
      );
    } else {
      final value = _getString(list[i]);
      if (value != null) {
        result[prefix == null ? "$key[$i]" : "$prefix[$key][$i]"] = value;
      }
    }
  }
  return result;
}

Future<http.Response?> get({
  required final String url,
  required final BuildContext context,
}) async {
  try {
    final headers = {
      HttpHeaders.acceptHeader: 'application/json',
    };
    final response = await http.get(Uri.parse(url), headers: headers);
    await checkExceptions(response: response, context: context);
    return response;
  } catch (e) {
    if (e is SocketException) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Something went wrong'),
        ),
      );
    } else {
      rethrow;
    }
  }
}

Future<http.Response?> authorizedGet({
  required final BuildContext context,
  required final String url,
}) async {
  try {
    final headers = {
      HttpHeaders.acceptHeader: 'application/json',
    };
    final token = Provider.of<AuthState>(context, listen: false).token;
    headers[HttpHeaders.authorizationHeader] = "Bearer $token";

    final response = await http.get(Uri.parse(url), headers: headers);
    await checkExceptions(response: response, context: context);
    return response;
  } catch (e) {
    if (e is SocketException) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Something went wrong'),
        ),
      );
    } else {
      rethrow;
    }
  }
}

Future<http.Response?> post({
  required final String url,
  required final BuildContext context,
  final Map? body,
  final bool jsonContent = false,
}) async {
  try {
    final headers = {
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (jsonContent) {
      headers[HttpHeaders.contentTypeHeader] = 'application/json';
    }
    final response = body == null
        ? await http.post(Uri.parse(url), headers: headers)
        : await http.post(Uri.parse(url), headers: headers, body: body);
    await checkExceptions(response: response, context: context);
    return response;
  } catch (e) {
    if (e is SocketException) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Something went wrong'),
        ),
      );
    } else {
      rethrow;
    }
  }
}

Future<http.Response?> authorizedPost({
  required final String url,
  required final BuildContext context,
  final Map? body,
  final bool jsonContent = false,
}) async {
  try {
    final headers = {
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (jsonContent) {
      headers[HttpHeaders.contentTypeHeader] = 'application/json';
    }
    final token = Provider.of<AuthState>(context, listen: false).token;
    headers[HttpHeaders.authorizationHeader] = "Bearer $token";
    final response = body == null
        ? await http.post(Uri.parse(url), headers: headers)
        : await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonContent ? json.encode(body) : body,
          );
    await checkExceptions(response: response, context: context);
    return response;
  } catch (e) {
    if (e is SocketException) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Something went wrong'),
        ),
      );
    } else {
      rethrow;
    }
  }
}

Future<http.Response?> authorizedDelete({
  required final String url,
  required final BuildContext context,
}) async {
  try {
    final headers = {
      HttpHeaders.acceptHeader: 'application/json',
    };
    final token = Provider.of<AuthState>(context, listen: false).token;
    headers[HttpHeaders.authorizationHeader] = "Bearer $token";
    final response = await http.delete(Uri.parse(url), headers: headers);

    await checkExceptions(response: response, context: context);
    return response;
  } catch (e) {
    if (e is SocketException) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Something went wrong'),
        ),
      );
    } else {
      rethrow;
    }
  }
}

Future<http.Response?> authorizedMultipart({
  required final String url,
  required final BuildContext context,
  required final Map body,
  final Map<String, String>? filePath,
  final Map<String, List<String>>? filesPath,
}) async {
  try {
    final headers = {
      HttpHeaders.acceptHeader: 'application/json',
    };
    final token = Provider.of<AuthState>(context, listen: false).token;
    headers[HttpHeaders.authorizationHeader] = "Bearer $token";
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    // Adding multiple files for one key
    if (filesPath != null) {
      filesPath.forEach((key, values) async {
        for (var value in values) {
          final file = await http.MultipartFile.fromPath(key, value);
          request.files.add(file);
        }
      });
    }

    // Adding single file for one key
    if (filePath != null) {
      filePath.forEach((key, value) async {
        request.files.add(await http.MultipartFile.fromPath(key, value));
      });
    }
    request.fields.addAll(_flattenMap(body));
    request.headers.addAll(headers);
    final response = await http.Response.fromStream(await request.send());
    await checkExceptions(response: response, context: context);
    return response;
  } catch (e) {
    if (e is SocketException) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Something went wrong'),
        ),
      );
    } else if (e is ConcurrentModificationError) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Please try again'),
        ),
      );
    } else {
      rethrow;
    }
  }
}