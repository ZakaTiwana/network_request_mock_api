import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:network_request_backend/models/error.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/user.dart';

class UserRouter {
  static const prefix = '/user';
  static final instance = UserRouter();
  UserRouter() {
    _setup();
  }

  final router = Router();

  void _setup() {
    _getError();
    _uploadProfilePic();
    _getAllUsers();
    _postUser();
    _getUser();
  }

  // Get User Routes
  void _getAllUsers() => router.get('/', _Handler.fetchAllUsers);
  void _getUser() => router.get('/<id>', _Handler.fetchUser);

  // Post User Routes
  void _postUser() => router.post('/', _Handler.addUser);

  // Upload Picture
  void _uploadProfilePic() =>
      router.post('/<id>/pic', _Handler.uploadProfilePic);

  // Mock error
  void _getError() => router.get('/error/<id>', _Handler.error);
}

// Handler

class _Handler {
  static Response fetchAllUsers(Request request) {
    return Response.ok(
      jsonEncode(
        List.generate(
            10, (index) => User(index, 'Mock Name $index', null).toMap()),
      ),
    );
  }

  static Response fetchUser(Request request, String id) {
    final userId = int.tryParse(id);
    if (userId == null) {
      return Response.badRequest(
        body: jsonEncode(Error(400, 'id should be Integer')),
      );
    }
    return Response.ok(
      jsonEncode(User(userId, 'Mock Name $userId', null).toMap()),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
  }

  static Future<Response> addUser(Request request) async {
    final bodyString = await request.readAsString();
    if (bodyString.isEmpty) {
      return Response.badRequest(
        body: jsonEncode(
          Error(400, 'body cannot be null').toMap(),
        ),
      );
    }
    try {
      final User user;
      switch (request.mimeType) {
        case 'application/x-www-form-urlencoded':
          final uriData = Uri.decodeQueryComponent(bodyString)
              .split('&')
              .map<MapEntry<String, String>>(
                (e) => MapEntry(e.split('=').first, e.split('=').last),
              );
          final data = Map<String, String>.fromEntries(uriData);
          final id = int.tryParse(data['id'] ?? '');
          final name = data['name'] ?? '';
          if (id == null) {
            return Response.badRequest(
              body: jsonEncode(Error(400, 'id field is required').toMap()),
            );
          }
          if (name.isEmpty) {
            return Response.badRequest(
              body: jsonEncode(Error(400, 'name field is required').toMap()),
            );
          }
          user = User(
            id,
            name,
            data['profilePic'],
          );
          break;
        default:
          user = jsonDecode(bodyString);
          break;
      }
      print(user);
      return Response.ok(null);
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode(
          Error(400, 'Could not decode body').toMap(),
        ),
      );
    }
  }

  static Future<Response> uploadProfilePic(
      Request request, String userId) async {
    final id = int.tryParse(userId) ?? 0;
    if (request.mimeType != 'multipart/form-data') {
      return Response.badRequest(
        body: jsonEncode(
          Error(400, 'Only multipart/form-data Content-Type is supported')
              .toMap(),
        ),
      );
    }
    final String boundary;
    try {
      final contentTypeHeader = request.headers[HttpHeaders.contentTypeHeader];
      boundary = RegExp(r'boundary=(.*)')
              .firstMatch(contentTypeHeader ?? '')
              ?.group(1) ??
          '';
      if (boundary.isEmpty) throw StateError('need boundary');
    } catch (_) {
      return Response.badRequest(
        body: jsonEncode(
          Error(404, 'Content-Type with boundary is required in header')
              .toMap(),
        ),
      );
    }

    final transformer = MimeMultipartTransformer(boundary);
    final parts = await transformer.bind(request.read()).toList();
    bool hasFile = false;
    for (var part in parts) {
      final contentDispose = part.headers['content-disposition'] ?? '';
      final fieldName =
          RegExp(r'name="([^"]*)"').firstMatch(contentDispose)?.group(1) ?? '';
      switch (fieldName) {
        case 'test':
          final content = await part.toList();
          if (content.isNotEmpty) print(String.fromCharCodes(content.first));
          break;
        case 'file':
          hasFile = true;
          final content = await part.toList();
          final filename = RegExp(r'filename="([^"]*)"')
                  .firstMatch(contentDispose)
                  ?.group(1) ??
              '$id';
          File('./public/pic/$filename').writeAsBytes(content.first);
          break;
        default:
          break;
      }
    }
    if (!hasFile) {
      return Response.badRequest(
        body: jsonEncode(Error(400, 'file is required').toMap()),
      );
    }
    return Response.ok("OK");
  }

  static Response error(Request request, String id) {
    return Response.notFound(
      jsonEncode(
        Error(404, 'could not find user with id = $id').toMap(),
      ),
    );
  }
}
