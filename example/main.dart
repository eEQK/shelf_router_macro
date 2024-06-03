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
  String greetingByName(String name) {
    return 'Hello, $name!';
  }

  @Get('/async/wave')
  Future<String> asyncWave() async {
    await Future.delayed(const Duration(seconds: 1));
    return r'\o_';
  }
}

const host = 'localhost';
const port = 8080;

void main() async {
  final controller = GreetingController();
  unawaited(
    serve(controller.router, host, port),
  );

  print('🔍 Testing...\n');
  await HttpClient().get(host, port, '/').sendAndLog();
  await HttpClient().get(host, port, '/eeqk').sendAndLog();
  await HttpClient().get(host, port, '/async/wave').sendAndLog();

  print('\n');
  print('✅ Server is running at http://$host:$port/');
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
