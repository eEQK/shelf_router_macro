import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router_macro/shelf_router_macro.dart';

@Controller()
class GreetingController {
  @Get('/')
  Response greeting(Request request) {
    return Response.ok('Hello, world!');
  }

  @Get('/<name>')
  Response greetingByName(Request request, String name) {
    return Response.ok('Hello, $name!');
  }
}

void main() async {
  final controller = GreetingController();
  unawaited(
    serve(controller.router, 'localhost', 8080),
  );

  print('🔍 Testing...\n');
  await HttpClient().get('localhost', 8080, '/').sendAndLog();
  await HttpClient().get('localhost', 8080, '/eeqk').sendAndLog();

  print('\n');
  print('✅ Server is running at http://localhost:8080/');
}

extension SendRequestExt on Future<HttpClientRequest> {
  Future<void> sendAndLog() async {
    final request = await this;
    final response = await request.close();

    print('📡 Request: ${request.method} ${request.uri}');
    print('${response.statusCode} ${response.reasonPhrase}');
    print(await response.transform(utf8.decoder).join());
  }
}
