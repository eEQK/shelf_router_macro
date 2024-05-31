import 'package:macros/macros.dart';

// this import: `package:shelf_router/shelf_router.dart`
// needs to be included, otherwise macro fails
// ignore: unused_import
import 'package:shelf_router/shelf_router.dart';

import '_common.dart';

/// {@template Controller}
/// A macro that marks class as a controller.
///
/// This macro:
/// - adds default constructor
/// - adds `router` field
/// - registers all detected routes
///
/// ```dart
/// @Controller()
/// class MyController {
///   @Get('/hello')
///   Response hello(Request r) => Response.ok('Hello');
/// }
/// ```
///
/// See also:
///
///  * [Get], [Post], [Put], [Delete], [Patch], [Connect] [Options], [Trace]
///    which register routes
/// {@endtemplate}
macro class Controller implements ClassDeclarationsMacro {
  /// {@macro Controller}
  const Controller();

  @override
  Future<void> buildDeclarationsForClass(
      ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final methods = await builder.methodsOf(clazz);
    final generatedMethods = methods
        .where((e) => e.identifier.name.startsWith(Common.generatedPrefix))
        .toList();

    builder.declareInLibrary(
      DeclarationCode.fromString(
        r"import 'package:shelf_router/src/router.dart';",
      ),
    );

    // ignore: deprecated_member_use
    final router = await builder.resolveIdentifier(
      Uri.parse('package:shelf_router/src/router.dart'),
      'Router',
    );
    builder.declareInType(
      DeclarationCode.fromParts(
          ['final ', router, ' router = ', router, '();']),
    );

    builder.declareInType(
      DeclarationCode.fromString('''${clazz.identifier.name}() {
          ${generatedMethods.map((e) => '${e.identifier.name}();').join('\n')}
        }'''),
    );
  }
}
