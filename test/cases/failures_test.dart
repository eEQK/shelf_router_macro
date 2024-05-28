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
  });
  tearDown(() {
    reset(builderMock);
  });

  final isErrorDiagnostic =
      isA<Diagnostic>().having((d) => d.severity, 'severity', Severity.error);

  test('fails when no param of type Request is present', () {
    Get('/').buildDeclarationsForMethod(
      Fixtures.method(/* void test() {} */),
      builderMock,
    );

    verify(() => builderMock.report(any(that: isErrorDiagnostic))).called(1);
  });

  test('fails when multiple params of type Request are present', () {
    Get('/').buildDeclarationsForMethod(
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

  test('fails when route param is not used', () {
    Get('/<foo>').buildDeclarationsForMethod(
      Fixtures.method(
        /* void test(Request r) {} */
        positionalParameters: [Fixtures.requestParam],
      ),
      builderMock,
    );

    verify(() => builderMock.report(any(that: isErrorDiagnostic))).called(1);
  });

  test('fails when method param does not exist in route', () {
    Get('/').buildDeclarationsForMethod(
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

  test('fails when route param declared in method as optional', () {
    Get('/').buildDeclarationsForMethod(
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
}
