import 'package:collection/collection.dart';
// ignore: implementation_imports
import 'package:macros/src/executor/introspection_impls.dart';
import 'package:macros/macros.dart';
import 'package:meta/meta.dart';
// ignore: implementation_imports
import 'package:shelf_router/src/router_entry.dart' show RouterEntry;
import 'package:shelf_router_macro/src/_common.dart';
import 'package:shelf_router_macro/src/_utils.dart';

part '_resolver.dart';

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
  required TypeAnnotation methodReturnType,
  required List<FormalParameterDeclaration> parameters,
  required MemberDeclarationBuilder builder,
}) async {
  final resolver = _Resolver(builder);
  final requestTypeDeclaration = await resolver.getRequestDeclaration();
  final responseTypeDeclaration = await resolver.getResponseDeclaration();

  final routeParameters = RouterEntry(verb, route, () => null).params;
  final methodParameters = await _processParameters(parameters, builder);

  final parameterDiff = _calculateParameterDifference(
    methodParameters: methodParameters
        // skip [Request] because it is shelf specific and cannot be used in route
        .whereNot((e) => e.typeDeclaration == requestTypeDeclaration),
    routeParameters: routeParameters,
  );
  if (parameterDiff.isNotEmpty) {
    throw ArgumentError.value(
      parameterDiff.join(', '),
      'parameters',
      'route and method parameters must match',
    );
  }

  final optionalParameters =
      methodParameters.whereNot((e) => e.value.isRequired).toList();
  if (optionalParameters.isNotEmpty) {
    throw ArgumentError.value(
      optionalParameters,
      'parameters',
      'have to be required (no optional parameters allowed)',
    );
  }

  final (lambdaParams, methodParams) = _computeParameters(
    methodParameters: methodParameters,
    shelfRequestTypeDeclaration: requestTypeDeclaration,
  );

  if (methodReturnType is! NamedTypeAnnotation) {
    throw ArgumentError.value(
      methodReturnType,
      'methodReturnType',
      'method must return a named type (no function or record type allowed)',
    );
  }
  final returnType =
      await builder.typeDeclarationOf(methodReturnType.identifier);
  if (returnType is! ClassDeclaration) {
    throw ArgumentError.value(
      methodReturnType,
      'methodReturnType',
      'method return type has to be a class declaration',
    );
  }

  var callback = <Object>['$methodName(', ...methodParams, ')'];

  final returnsFuture = returnType == await resolver.getFutureDeclaration();
  if (returnsFuture) {
    // method is async

    final futureResultIdentifier =
        (methodReturnType.typeArguments.first as NamedTypeAnnotationImpl)
            .identifier;
    final futureResultClass =
        await resolver._resolveClass(futureResultIdentifier);

    if (futureResultClass == responseTypeDeclaration) {
      // pass
    } else if (futureResultClass == await resolver.getStringDeclaration()) {
      callback = callback.followedBy(
          ['.then(', responseTypeDeclaration.identifier, '.ok)']).toList();
    } else {
      throw ArgumentError.value(
        methodReturnType,
        'methodReturnType',
        'future type parameter must be a Response or String',
      );
    }
  } else {
    // method is sync

    final returnsResponse = returnType == responseTypeDeclaration;
    if (!returnsResponse) {
      if (returnType == await resolver.getStringDeclaration()) {
        callback = callback.surroundWith(
          prefix: [responseTypeDeclaration.identifier, '.ok('],
          postfix: [')'],
        ).toList();
      } else {
        throw ArgumentError.value(
          parameters,
          'parameters',
          'return type must be a Response or String',
        );
      }
    }
  }

  return DeclarationCode.fromParts(
    [
      '''
        ${Common.generatedPrefix}$methodName() {
        router.add('$verb', '$route', (''',
      ...lambdaParams,
      ''') => ''',
      ...callback,
      ''');
        }
      ''',
    ],
  );
}

(List<Object>, List<Object>) _computeParameters({
  required List<_Parameter> methodParameters,
  required ClassDeclaration shelfRequestTypeDeclaration,
}) {
  final shelfRequestParameter = _findShelfRequestParameter(
    methodParameters: methodParameters,
    shelfRequestTypeDeclaration: shelfRequestTypeDeclaration,
  );

  // this will fail if library consumer adds a `_` parameter,
  // however once wildcard variables land, this will not be an issue
  // because it will be not binding
  //
  // todo: once wildcard variables are out, remove this comment
  // https://github.com/dart-lang/language/issues/3712
  final requestParamName = shelfRequestParameter?.name ?? '_';
  final lambdaParams = <Object?>[
    shelfRequestTypeDeclaration.identifier,
    ' ',
    requestParamName,
  ]
      .followedBy(methodParameters
          .whereNot((e) => e == shelfRequestParameter)
          .expand((e) => [
                ', ',
                e.type.identifier,
                ' ',
                e.value.name,
              ]))
      .whereNotNull()
      .toList();
  final methodParams = methodParameters
      .map((e) => e.isNamed ? '${e.name}: ${e.name}' : e.name)
      .separatedBy(', ')
      .toList();

  return (lambdaParams, methodParams);
}

_Parameter? _findShelfRequestParameter({
  required List<_Parameter> methodParameters,
  required ClassDeclaration shelfRequestTypeDeclaration,
}) {
  final shelfRequestParameters = methodParameters
      .where((e) => e.typeDeclaration == shelfRequestTypeDeclaration);
  if (shelfRequestParameters.length > 1) {
    throw ArgumentError.value(
      methodParameters
          .map((e) => '${e.type.identifier.name} ${e.name}')
          .join(', '),
      'parameters',
      'method must have at most one parameter of type Request',
    );
  }

  return shelfRequestParameters.firstOrNull;
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
