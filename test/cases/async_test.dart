import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router_macro/shelf_router_macro.dart';
import 'package:test/test.dart';

import '../utils.dart';

@Controller()
class _Controller {
  @Get('/future')
  Future<Response> test1(Request r) async {
    return Response.ok('ok');
  }

  @Get('/future/no-request')
  Future<Response> test2() async {
    return Response.ok('ok');
  }

  @Get('/future/no-response')
  Future<String> test3(Request r) async {
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

  test('registers async route', () async {
    final response = await get(port, '/future');
    await expectLater(response, ok('ok'));
  });
  test('registers async route without Request param', () async {
    final response = await get(port, '/future/no-request');
    await expectLater(response, ok('ok'));
  });
  test('registers async route without Response param', () async {
    final response = await get(port, '/future/no-response');
    await expectLater(response, ok('ok'));
  });
}
