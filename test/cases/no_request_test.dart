import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router_macro/shelf_router_macro.dart';
import 'package:test/test.dart';

import '../utils.dart';

@Controller()
class _Controller {
  @Get('/no-request')
  Response test1() {
    return Response.ok('ok');
  }

  @Get('/no-response')
  String test2(Request r) {
    return 'ok';
  }

  @Get('/no-request-response')
  String test3() {
    return 'ok';
  }
}

void main() {
  late HttpServer server;
  final port = ServerPort.unique;

  setUpAll(
    () async => server = await serve(_Controller().router, 'localhost', port),
  );
  tearDownAll(
    () => server.close(force: true),
  );

  test('registers route without specifying Request', () async {
    final response = await get(port, '/no-request');
    await expectLater(response, ok('ok'));
  });
  test('registers route without specifying Response', () async {
    final response = await get(port, '/no-response');
    await expectLater(response, ok('ok'));
  });
  test('registers route without specifying Response and Request', () async {
    final response = await get(port, '/no-request-response');
    await expectLater(response, ok('ok'));
  });
}
