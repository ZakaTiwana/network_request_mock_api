import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class AuthRouter {
  static const prefix = '/auth';
  static final instance = AuthRouter();
  AuthRouter() {
    _setup();
  }

  final router = Router();

  void _setup() {
    _refreshUser();
    _triggerUnAuth();
  }

  // Routes
  void _refreshUser() => router.post('/refresh', _Handler.refreshUser);
  void _triggerUnAuth() => router.patch('/unauth', _Handler.unAuthUser);
}

// Handler

class _Handler {
  static Future<Response> refreshUser(Request request) async {
    await Future.delayed(Duration(seconds: 1));
    Map<String, String> authData = {
      "token": "token",
      "refreshToken": "refreshToken"
    };
    return Response.ok(
      jsonEncode(authData),
    );
  }

  static var shouldShowUnAuth = true;
  static Future<Response> unAuthUser(Request request) async {
    await Future.delayed(Duration(seconds: 1));
    if (shouldShowUnAuth == false) {
      shouldShowUnAuth = true;
      return Response.ok('user authorized');
    }
    shouldShowUnAuth = false;
    return Response.unauthorized('user unauthorized');
  }
}
