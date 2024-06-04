part of '_http_verb_builder.dart';

/// A service class to help resolve types/identifiers.
///
/// Has to be created per macro invocation
class _Resolver {
  _Resolver(this._introspector);

  final DeclarationPhaseIntrospector _introspector;

  Future<ClassDeclaration> getRequestDeclaration() =>
      resolveClass('package:shelf/src/request.dart', 'Request');
  Future<ClassDeclaration> getResponseDeclaration() =>
      resolveClass('package:shelf/src/response.dart', 'Response');
  Future<ClassDeclaration> getStringDeclaration() =>
      resolveClass('dart:core', 'String');
  Future<ClassDeclaration> getFutureDeclaration() =>
      resolveClass('dart:async', 'Future');
  Future<ClassDeclaration> getJsonCodecDeclaration() =>
      resolveClass('dart:convert', 'JsonCodec');

  Future<ClassDeclaration> resolveClass(String uri, String name) async =>
      (await _introspector.typeDeclarationOf(await _identifierOf(uri, name)))
          as ClassDeclaration;
  Future<ClassDeclaration> resolveClassWith(IdentifierImpl identifier) async =>
      (await _introspector.typeDeclarationOf(identifier)) as ClassDeclaration;

  Future<Identifier> _identifierOf(String uri, String name) =>
      // ignore: deprecated_member_use
      _introspector.resolveIdentifier(
        Uri.parse(uri),
        name,
      );
}
