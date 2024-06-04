import 'dart:convert';
import 'dart:io';

import 'package:json/json.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router_macro/shelf_router_macro.dart';
import 'package:test/test.dart';

import '../utils.dart';

@JsonCodable()
class Foo {
  Foo({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}

@Controller()
class _Controller {
  @Get('/sync')
  Foo test1() => Foo(id: 1, name: 'sync');

  @Get('/async')
  Future<Foo> test2() async => Foo(id: 2, name: 'async');
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

  test('decodes returned type into json', () async {
    final response = await get(port, '/sync');
    await expectLater(
      response,
      ok(jsonEncode({'id': 1, 'name': 'sync'})),
    );
  });

  test('decodes returned type into json for an async route', () async {
    final response = await get(port, '/async');
    await expectLater(
      response,
      ok(jsonEncode({'id': 2, 'name': 'async'})),
    );
  });
}
