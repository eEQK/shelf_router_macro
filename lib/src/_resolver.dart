part of '_http_verb_builder.dart';

/// A service class to help resolve types/identifiers.
///
/// Has to be created per macro invocation
class _Resolver {
  _Resolver(this._introspector);

  final DeclarationPhaseIntrospector _introspector;

  Future<ClassDeclaration> getRequestDeclaration() async =>
      _resolveClass(await _getRequestIdentifier());
  Future<Identifier> _getRequestIdentifier() =>
      // ignore: deprecated_member_use
      _introspector.resolveIdentifier(
        Uri.parse('package:shelf/src/request.dart'),
        'Request',
      );

  Future<ClassDeclaration> getResponseDeclaration() async =>
      _resolveClass(await _getResponseIdentifier());
  Future<Identifier> _getResponseIdentifier() =>
      // ignore: deprecated_member_use
      _introspector.resolveIdentifier(
        Uri.parse('package:shelf/src/response.dart'),
        'Response',
      );

  Future<ClassDeclaration> getStringDeclaration() async =>
      _resolveClass(await _getStringIdentifier());
  Future<Identifier> _getStringIdentifier() =>
      // ignore: deprecated_member_use
      _introspector.resolveIdentifier(
        Uri.parse('dart:core'),
        'String',
      );

  Future<ClassDeclaration> getFutureDeclaration() async =>
      _resolveClass(await _getFutureIdentifier());
  Future<Identifier> _getFutureIdentifier() =>
      // ignore: deprecated_member_use
      _introspector.resolveIdentifier(
        Uri.parse('dart:async'),
        'Future',
      );

  Future<ClassDeclaration> _resolveClass(
    Identifier identifier,
  ) async =>
      (await _introspector.typeDeclarationOf(identifier)) as ClassDeclaration;
}
