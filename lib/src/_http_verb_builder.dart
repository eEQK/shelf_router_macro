import 'package:collection/collection.dart';
import 'package:macros/macros.dart';
import 'package:meta/meta.dart';
import 'package:shelf_router/src/router_entry.dart' show RouterEntry;

/// A prefix for generated methods
///
/// Will be made redundant once meta support for macros lands
@internal
const generatedPrefix = '_\$shelf_';

/// Build a declaration for a method marked with HTTP verb macro
@internal
DeclarationCode buildHttpVerbDeclaration({
  required String verb,
  required String route,
  required String methodName,
  required List<FormalParameterDeclaration> parameters,
}) {
  final routeParameters = RouterEntry(verb, route, () => null).params;

  _validateInput(
    verb: verb,
    route: route,
    methodName: methodName,
    parameters: parameters,
    routeParameters: routeParameters,
  );

  final lambdaParams = parameters
      .expandIndexed((i, e) => [
            i != 0 ? ', ' : null,
            e.type.code,
            ' ${e.name}',
          ])
      .whereNotNull();
  final methodParams = parameters
      .map((e) => e.isNamed ? '${e.name}: ${e.name}' : e.name)
      .join(', ');

  return DeclarationCode.fromParts(
    [
      '''
        $generatedPrefix$methodName() {
        router.add('$verb', '$route', (''',
      ...lambdaParams,
      ''') => $methodName($methodParams));
        }
      ''',
    ],
  );
}

void _validateInput({
  required String verb,
  required String route,
  required String methodName,
  required List<FormalParameterDeclaration> parameters,
  required List<String> routeParameters,
}) {
  final nonNamedTypes =
      parameters.where((e) => e.type is! NamedTypeAnnotation).toList();
  if (nonNamedTypes.isNotEmpty) {
    throw ArgumentError.value(
      nonNamedTypes.map((e) => e.name).join(', '),
      'parameters',
      'only named parameters are supported',
    );
  }

  final optionalParams = parameters.where((e) => !e.isRequired).toList();
  if (optionalParams.isNotEmpty) {
    throw ArgumentError.value(
      optionalParams.join(', '),
      'parameters',
      'optional parameters are not supported',
    );
  }

  final types =
      parameters.map((e) => e.type).cast<NamedTypeAnnotation>().toList();
  final requestIdentifier = types
      .map((e) => e.identifier)
      .firstWhereOrNull((e) => e.name == 'Request');

  late final routerParams = parameters
      .map((e) => e.type as NamedTypeAnnotation)
      .where((e) => e.identifier == requestIdentifier)
      .toList();
  if (requestIdentifier == null || routerParams.length != 1) {
    throw ArgumentError.value(
      parameters
          .map((e) =>
              '${(e.type as NamedTypeAnnotation).identifier.name} ${e.name}')
          .join(', '),
      'parameters',
      'method must have exactly one parameter of type Request',
    );
  }

  final routeSet = routeParameters.toSet();
  final methodSet = parameters
      .whereNot((e) =>
          (e.type as NamedTypeAnnotation).identifier == requestIdentifier)
      .map((e) => e.name)
      .toSet();

  final routeParamDiff = routeSet.difference(methodSet);
  if (routeParamDiff.isNotEmpty) {
    throw ArgumentError.value(
      routeParamDiff.join(', '),
      'route',
      'all route params must be declared as method parameters',
    );
  }

  final methodParamDiff = methodSet.difference(routeSet);
  if (methodParamDiff.isNotEmpty) {
    throw ArgumentError.value(
      methodParamDiff.join(', '),
      'route',
      'all method parameters must be declared in route',
    );
  }
}
