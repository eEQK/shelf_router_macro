import 'package:macros/src/executor/introspection_impls.dart';
import 'package:macros/src/executor/remote_instance.dart';

/// this class abstracts away macros internals
class Fixtures {
  static final library = LibraryImpl(
    id: RemoteInstance.uniqueId,
    languageVersion: LanguageVersionImpl(3, 0),
    metadata: [],
    uri: Uri.parse('package:foo/bar.dart'),
  );
  static final shelfLibrary = LibraryImpl(
    id: RemoteInstance.uniqueId,
    languageVersion: LanguageVersionImpl(3, 0),
    metadata: [],
    uri: Uri.parse('package:shelf/shelf.dart'),
  );

  static final fooIdentifier = identifier(name: 'foo');

  static final requestType = NamedTypeAnnotationImpl(
      id: RemoteInstance.uniqueId,
      identifier: identifier(name: 'Request'),
      isNullable: false,
      typeArguments: const []);
  static final requestParam = FormalParameterDeclarationImpl(
    id: RemoteInstance.uniqueId,
    library: shelfLibrary,
    identifier: identifier(name: 'r'),
    type: requestType,
    metadata: [],
    isNamed: false,
    isRequired: true,
  );

  static final stringType = NamedTypeAnnotationImpl(
      id: RemoteInstance.uniqueId,
      identifier: identifier(name: 'String'),
      isNullable: false,
      typeArguments: const []);
  static final nullableStringType = NamedTypeAnnotationImpl(
      id: RemoteInstance.uniqueId,
      identifier: identifier(name: 'String'),
      isNullable: true,
      typeArguments: const []);
  static final voidType = NamedTypeAnnotationImpl(
      id: RemoteInstance.uniqueId,
      identifier: identifier(name: 'void'),
      isNullable: false,
      typeArguments: const []);

  static identifier({
    required String name,
  }) =>
      IdentifierImpl(id: RemoteInstance.uniqueId, name: name);

  /// Returns method declaration with sane defaults
  ///
  /// By default represents a method `test` within this code:
  /// ```dart
  /// class Test {
  ///   void test() {}
  /// }
  /// ```
  static method({
    IdentifierImpl? identifier,
    NamedTypeAnnotationImpl? returnType,
    List<FormalParameterDeclarationImpl> namedParameters = const [],
    List<FormalParameterDeclarationImpl> positionalParameters = const [],
  }) =>
      MethodDeclarationImpl(
        id: RemoteInstance.uniqueId,
        identifier: identifier ?? Fixtures.identifier(name: 'test'),
        library: Fixtures.library,
        metadata: [],
        hasBody: true,
        hasExternal: false,
        isGetter: false,
        isOperator: false,
        isSetter: false,
        namedParameters: namedParameters,
        positionalParameters: positionalParameters,
        returnType: returnType ?? voidType,
        typeParameters: [],
        definingType: IdentifierImpl(id: RemoteInstance.uniqueId, name: 'Test'),
        hasStatic: false,
      );

  /// Returns parameter declaration with sane defaults
  ///
  /// By default represents the following (positional required) parameter:
  /// ```dart
  /// String foo
  /// ```
  static parameter({
    IdentifierImpl? identifier,
    NamedTypeAnnotationImpl? type,
    bool isNamed = false,
    bool isRequired = true,
  }) =>
      FormalParameterDeclarationImpl(
        id: RemoteInstance.uniqueId,
        library: Fixtures.library,
        identifier: identifier ?? fooIdentifier,
        type: type ?? stringType,
        metadata: [],
        isNamed: isNamed,
        isRequired: isRequired,
      );
}
