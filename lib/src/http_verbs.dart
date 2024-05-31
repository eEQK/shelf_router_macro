import 'package:macros/macros.dart';
import 'package:shelf_router_macro/src/_http_verb_builder.dart';

/// {@template HttpVerb}
/// A macro that in combination with
/// [Controller] macro will register a route
///
/// Requirements:
/// - method must be inside a class annotated with [Controller]
/// - method can't have optional parameters
/// - must return Response and accept a Request
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
///  * [Controller], which is required for a route to be registered.
/// {@endtemplate}
macro class Get implements MethodDeclarationsMacro {
  /// {@macro HttpVerb}
  const Get(this.route);

  /// {@template route}
  /// Route for this method
  ///
  /// **Examples**
  /// * `/users/<userName>`
  /// * `/users/<userName>/say-hello`
  /// * `/users/<userName>/whoami`
  /// * `/users/<userName>/messages/<msgId|\d+>`
  ///
  /// See also:
  /// * [shelf_router documentation](https://pub.dev/documentation/shelf_router/latest/shelf_router/Router-class.html), for an explanation of routes and routing
  /// {@endtemplate}
  final String route;

  @override
  Future<void> buildDeclarationsForMethod(method, builder) async {
    await _buildHttpVerbDeclaration(method, builder, "GET", route);
  }
}

/// {@macro HttpVerb}
macro class Post implements MethodDeclarationsMacro {
  /// {@macro HttpVerb}
  const Post(this.route);

  /// {@macro route}
  final String route;

  @override
  Future<void> buildDeclarationsForMethod(method, builder) async {
    await _buildHttpVerbDeclaration(method, builder, "POST", route);
  }
}

/// {@macro HttpVerb}
macro class Put implements MethodDeclarationsMacro {
  /// {@macro HttpVerb}
  const Put(this.route);

  /// {@macro route}
  final String route;

  @override
  Future<void> buildDeclarationsForMethod(method, builder) async {
    await _buildHttpVerbDeclaration(method, builder, "PUT", route);
  }
}

/// {@macro HttpVerb}
macro class Patch implements MethodDeclarationsMacro {
  /// {@macro HttpVerb}
  const Patch(this.route);

  /// {@macro route}
  final String route;

  @override
  Future<void> buildDeclarationsForMethod(method, builder) async {
    await _buildHttpVerbDeclaration(method, builder, "PATCH", route);
  }
}

/// {@macro HttpVerb}
macro class Delete implements MethodDeclarationsMacro {
  /// {@macro HttpVerb}
  const Delete(this.route);

  /// {@macro route}
  final String route;

  @override
  Future<void> buildDeclarationsForMethod(method, builder) async {
    await _buildHttpVerbDeclaration(method, builder, "DELETE", route);
  }
}

/// {@macro HttpVerb}
macro class Head implements MethodDeclarationsMacro {
  /// {@macro HttpVerb}
  const Head(this.route);

  /// {@macro route}
  final String route;

  @override
  Future<void> buildDeclarationsForMethod(method, builder) async {
    await _buildHttpVerbDeclaration(method, builder, "HEAD", route);
  }
}

/// {@macro HttpVerb}
macro class Options implements MethodDeclarationsMacro {
  /// {@macro HttpVerb}
  const Options(this.route);

  /// {@macro route}
  final String route;

  @override
  Future<void> buildDeclarationsForMethod(method, builder) async {
    await _buildHttpVerbDeclaration(method, builder, "OPTIONS", route);
  }
}

/// {@macro HttpVerb}
macro class Connect implements MethodDeclarationsMacro {
  /// {@macro HttpVerb}
  const Connect(this.route);

  /// {@macro route}
  final String route;

  @override
  Future<void> buildDeclarationsForMethod(method, builder) async {
    await _buildHttpVerbDeclaration(method, builder, "CONNECT", route);
  }
}

/// {@macro HttpVerb}
macro class Trace implements MethodDeclarationsMacro {
  /// {@macro HttpVerb}
  const Trace(this.route);

  /// {@macro route}
  final String route;

  @override
  Future<void> buildDeclarationsForMethod(method, builder) async {
    await _buildHttpVerbDeclaration(method, builder, "TRACE", route);
  }
}

Future<void> _buildHttpVerbDeclaration(
  MethodDeclaration method,
  MemberDeclarationBuilder builder,
  String verb,
  String route,
) async {
  try {
    final declaration = await buildHttpVerbDeclaration(
      verb: verb,
      route: route,
      builder: builder,
      methodName: method.identifier.name,
      parameters: method.positionalParameters
          .followedBy(method.namedParameters)
          .toList(),
    );

    builder.declareInType(declaration);
  } on ArgumentError catch (e) {
    builder.report(
      Diagnostic(
        DiagnosticMessage(e.toString()),
        Severity.error,
      ),
    );
  }
}
