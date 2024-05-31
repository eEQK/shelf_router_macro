import 'package:collection/collection.dart';
import 'package:macros/macros.dart';
import 'package:meta/meta.dart';
import 'package:shelf_router/src/router_entry.dart' show RouterEntry;
import 'package:shelf_router_macro/src/_common.dart';

/// Wrapper around [FormalParameterDeclaration] to store the type
///
/// This is used to make it easier to work with macro types
/// or to have data that is already validated (e.g. named type)
class _Parameter {
  _Parameter({
    required this.value,
    required this.type,
    required this.typeDeclaration,
  });

  final FormalParameterDeclaration value;
  final NamedTypeAnnotation type;
  final ClassDeclaration typeDeclaration;

  bool get isNamed => value.isNamed;
  String get name => value.name;
}

/// Build a declaration for a method marked with HTTP verb macro
@internal
Future<DeclarationCode> buildHttpVerbDeclaration({
  required String verb,
  required String route,
  required String methodName,
  required List<FormalParameterDeclaration> parameters,
  required MemberDeclarationBuilder builder,
}) async {
  // ignore: deprecated_member_use
  final requestIdentifier = await builder.resolveIdentifier(
      Uri.parse('package:shelf/src/request.dart'), 'Request');
  final shelfRequestTypeDeclaration =
      (await builder.typeDeclarationOf(requestIdentifier)) as ClassDeclaration;

  final routeParameters = RouterEntry(verb, route, () => null).params;
  final methodParameters = await _processParameters(parameters, builder);

  final parameterDiff = _calculateParameterDifference(
    methodParameters: methodParameters
        // skip [Request] because it is shelf specific and cannot be used in route
        .whereNot((e) => e.typeDeclaration == shelfRequestTypeDeclaration),
    routeParameters: routeParameters,
  );
  if (parameterDiff.isNotEmpty) {
    throw ArgumentError.value(
      parameterDiff.join(', '),
      'parameters',
      'route and method parameters must match',
    );
  }

  final shelfRequestParameters = methodParameters
      .where((e) => e.typeDeclaration == shelfRequestTypeDeclaration);
  if (shelfRequestParameters.length != 1) {
    throw ArgumentError.value(
      parameters
          .map((e) =>
              '${(e.type as NamedTypeAnnotation).identifier.name} ${e.name}')
          .join(', '),
      'parameters',
      'method must have exactly one parameter of type Request',
    );
  }

  final optionalParameters =
      methodParameters.whereNot((e) => e.value.isRequired).toList();
  if (optionalParameters.isNotEmpty) {
    throw ArgumentError.value(
      optionalParameters,
      'parameters',
      'has to be required (no optional parameters allowed)',
    );
  }

  final lambdaParams = methodParameters
      .expandIndexed((i, e) => [
            i != 0 ? ', ' : null,
            e.type.identifier,
            ' ',
            e.value.name,
          ])
      .whereNotNull();
  final methodParams = methodParameters
      .map((e) => e.isNamed ? '${e.name}: ${e.name}' : e.name)
      .join(', ');

  return DeclarationCode.fromParts(
    [
      '''
        ${Common.generatedPrefix}$methodName() {
        router.add('$verb', '$route', (''',
      ...lambdaParams,
      ''') => $methodName($methodParams));
        }
      ''',
    ],
  );
}

Set<String> _calculateParameterDifference({
  required Iterable<_Parameter> methodParameters,
  required Iterable<String> routeParameters,
}) {
  final method = methodParameters.map((e) => e.name).toSet();
  final route = routeParameters.toSet();

  return method.difference(route).followedBy(route.difference(method)).toSet();
}

Future<List<_Parameter>> _processParameters(
  List<FormalParameterDeclaration> parameters,
  MemberDeclarationBuilder builder,
) async {
  final result = <_Parameter>[];

  for (final parameter in parameters) {
    final type = parameter.type is NamedTypeAnnotation
        ? parameter.type as NamedTypeAnnotation
        : throw ArgumentError.value(
            parameter,
            'parameters',
            'type has to be a NamedTypeAnnotation (no function or record type allowed)',
          );
    final typeDeclaration = await builder.typeDeclarationOf(type.identifier);
    if (typeDeclaration is! ClassDeclaration) {
      throw ArgumentError.value(
        parameter,
        'parameters',
        'parameter type has to be a class declaration',
      );
    }

    result.add(_Parameter(
      value: parameter,
      type: type,
      typeDeclaration: typeDeclaration,
    ));
  }

  return result;
}
