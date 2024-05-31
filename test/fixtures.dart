import 'package:macros/macros.dart';
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
  static final dartCoreLibrary = LibraryImpl(
    id: RemoteInstance.uniqueId,
    languageVersion: LanguageVersionImpl(3, 0),
    metadata: [],
    uri: Uri.parse('dart:core'),
  );
  static final shelfLibrary = LibraryImpl(
    id: RemoteInstance.uniqueId,
    languageVersion: LanguageVersionImpl(3, 0),
    metadata: [],
    uri: Uri.parse('package:shelf/shelf.dart'),
  );

  static final fooIdentifier = identifier(name: 'foo');

  static final responseType = NamedTypeAnnotationImpl(
      id: RemoteInstance.uniqueId,
      identifier: identifier(name: 'Response'),
      isNullable: false,
      typeArguments: const []);
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

  static IdentifierImpl identifier({
    required String name,
  }) =>
      TestIdentifierImpl(id: RemoteInstance.uniqueId, name: name);

  /// Returns class declaration with sane defaults
  ///
  /// By default represents the following class:
  /// ```dart
  /// class Test {
  /// }
  /// ```
  static ClassDeclaration clazz({
    IdentifierImpl? identifier,
    LibraryImpl? library,
  }) =>
      ClassDeclarationImpl(
        id: RemoteInstance.uniqueId,
        identifier: identifier ?? Fixtures.identifier(name: 'Test'),
        library: library ?? Fixtures.library,
        metadata: [],
        typeParameters: [],
        interfaces: [],
        mixins: [],
        superclass: null,
        hasExternal: false,
        hasBase: false,
        hasFinal: false,
        hasMixin: false,
        hasSealed: false,
        hasAbstract: false,
        hasInterface: false,
      );

  /// Returns method declaration with sane defaults
  ///
  /// By default represents a method `test` within this code:
  /// ```dart
  /// class Test {
  ///   void test() {}
  /// }
  /// ```
  static MethodDeclarationImpl method({
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
  static FormalParameterDeclarationImpl parameter({
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

/// custom class that adds [toString] for easier debugging
///
/// this way we can see which identifier is being requested in mocktail
class TestIdentifierImpl extends IdentifierImpl {
  TestIdentifierImpl({required super.id, required super.name});

  @override
  String toString() => 'IdentifierImpl(id: $id, name: $name)';
}
