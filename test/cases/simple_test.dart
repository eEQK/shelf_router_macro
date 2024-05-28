import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router_macro/shelf_router_macro.dart';
import 'package:test/test.dart';

import '../utils.dart';

@Controller()
class _Controller {
  @Get('/')
  Response hello(Request request) {
    return Response.ok('hello');
  }

  @Get('/test')
  Response test(Request request) {
    return Response.ok('test');
  }

  @Get('/request/positional')
  Response requestPositional(Request r) {
    return Response.ok('req pos');
  }

  @Get('/request/named')
  Response requestNamed({required Request request}) {
    return Response.ok('req named');
  }

  @Get('/route/positional/<name>')
  Response helloName(Request request, String name) {
    return Response.ok('$name pos');
  }

  @Get('/route/named/<name>')
  Response named(Request request, {required String name}) {
    return Response.ok('$name named');
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

  test('registers a simple / route', () async {
    final response = await get(port, '/');
    expect(response, ok('hello'));
  });
  test('registers route with a path', () async {
    final response = await get(port, '/test');
    expect(response, ok('test'));
  });

  test('allows renaming Request arg', () async {
    final response = await get(port, '/request/positional');
    expect(response, ok('req pos'));
  });
  test('allows using named Request arg', () async {
    final response = await get(port, '/request/named');
    expect(response, ok('req named'));
  });

  test('registers route with a route param and positional arg', () async {
    final response = await get(port, '/route/positional/eeqk');
    expect(response, ok('eeqk pos'));
  });
  test('registers route with a route param and named arg', () async {
    final response = await get(port, '/route/named/eeqk');
    expect(response, ok('eeqk named'));
  });
}
