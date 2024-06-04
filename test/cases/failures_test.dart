import 'package:macros/macros.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shelf_router_macro/src/http_verbs.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

class MockDeclarationBuilder extends Mock implements MemberDeclarationBuilder {}

void main() {
  final builderMock = MockDeclarationBuilder();

  setUpAll(() {
    registerFallbackValue(Diagnostic(DiagnosticMessage(''), Severity.info));
    registerFallbackValue(Fixtures.identifier(name: ''));
    registerFallbackValue(Uri.parse(''));
    registerFallbackValue(DeclarationCode.fromString(''));
  });
  setUp(() {
    when(() => builderMock.report(any())).thenReturn(null);
    when(() => builderMock.declareInType(any())).thenReturn(null);

    when(() =>
            builderMock.resolveIdentifier(any(), any(that: equals('Response'))))
        .thenAnswer((_) async => Fixtures.responseType.identifier);
    when(() =>
            builderMock.resolveIdentifier(any(), any(that: equals('Request'))))
        .thenAnswer((_) async => Fixtures.requestType.identifier);

    when(() => builderMock.typeDeclarationOf(any(
          that: isA<Identifier>().having((e) => e.name, 'name', 'String'),
        ))).thenAnswer((_) async => Fixtures.clazz(
          identifier: Fixtures.stringType.identifier,
          library: Fixtures.dartCoreLibrary,
        ));
    when(() => builderMock.typeDeclarationOf(any(
          that: isA<Identifier>().having((e) => e.name, 'name', 'Response'),
        ))).thenAnswer((_) async => Fixtures.clazz(
          identifier: Fixtures.responseType.identifier,
          library: Fixtures.shelfLibrary,
        ));
    when(() => builderMock.typeDeclarationOf(any(
          that: isA<Identifier>().having((e) => e.name, 'name', 'Request'),
        ))).thenAnswer((_) async => Fixtures.clazz(
          identifier: Fixtures.requestType.identifier,
          library: Fixtures.shelfLibrary,
        ));
  });
  tearDown(() {
    reset(builderMock);
  });

  final isErrorDiagnostic =
      isA<Diagnostic>().having((d) => d.severity, 'severity', Severity.error);

  test('fails when multiple params of type Request are present', () async {
    await Get('/').buildDeclarationsForMethod(
      Fixtures.method(
        /* void test(Request r1, Request r2) {} */
        positionalParameters: [
          Fixtures.parameter(
            type: Fixtures.requestType,
            identifier: Fixtures.identifier(name: 'r1'),
          ),
          Fixtures.parameter(
            type: Fixtures.requestType,
            identifier: Fixtures.identifier(name: 'r2'),
          ),
        ],
      ),
      builderMock,
    );

    verify(() => builderMock.report(any(that: isErrorDiagnostic))).called(1);
  });

  test('fails when method param does not exist in route', () async {
    await Get('/').buildDeclarationsForMethod(
      Fixtures.method(
        /* void test(Request r, String foo) {} */
        positionalParameters: [
          Fixtures.requestParam,
          Fixtures.parameter(),
        ],
      ),
      builderMock,
    );

    verify(() => builderMock.report(any(that: isErrorDiagnostic))).called(1);
  });

  test('fails when route param does not exist in method', () async {
    await Get('/<foo>').buildDeclarationsForMethod(
      Fixtures.method(
        /* void test(Request r) {} */
        positionalParameters: [Fixtures.requestParam],
      ),
      builderMock,
    );

    verify(() => builderMock.report(any(that: isErrorDiagnostic))).called(1);
  });

  test('fails when route param declared in method as optional', () async {
    await Get('/').buildDeclarationsForMethod(
      Fixtures.method(
        /* void test(Request r, {String? foo}) {} */
        positionalParameters: [
          Fixtures.requestParam,
          Fixtures.parameter(
            type: Fixtures.nullableStringType,
            isNamed: true,
            isRequired: false,
          ),
        ],
      ),
      builderMock,
    );

    verify(() => builderMock.report(any(that: isErrorDiagnostic))).called(1);
  });

  test('fails when returning an instance that does not have toJson', () async {
    when(() => builderMock.typeDeclarationOf(any(
          that: isA<Identifier>().having((e) => e.name, 'name', 'Foo'),
        ))).thenAnswer(
      (_) async => Fixtures.clazz(identifier: Fixtures.fooType.identifier),
    );

    await Get('/').buildDeclarationsForMethod(
      Fixtures.method(
        /* 
          class Foo {}
          void test(Foo foo) {} 
        */
        positionalParameters: [
          Fixtures.parameter(
            type: Fixtures.fooType,
            isNamed: false,
            isRequired: false,
          ),
        ],
      ),
      builderMock,
    );

    verify(() => builderMock.report(any(that: isErrorDiagnostic))).called(1);
  });
}
