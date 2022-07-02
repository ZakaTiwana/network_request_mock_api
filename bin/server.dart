import 'package:network_request_backend/routes/user_route.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

void main(List<String> args) async {
  app.mount(UserRouter.prefix, UserRouter.instance.router);
  final cascade = Cascade()
      // First, serve files from the 'public' directory
      .add(_staticHandler)
      .add(app);

  // Configure a pipeline that logs requests.
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(cascade.handler);

  final server = await serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}

// Configure routes.
final app = Router();
final _staticHandler =
    createStaticHandler('public', defaultDocument: 'index.html');
