/// Experimental support for shelf_router using macros
///
/// This library provides a set of macros that can be used
/// to define [Router] routes.
///
/// Example:
/// ```dart
/// import 'package:data_class_macro/data_class_macro.dart';
///
/// @Controller()
/// class GreetingController {
///   @Get('/<name>')
///   Response greetingByName(Request request, String name) {
///     return Response.ok('Hello, $name!');
///   }
/// }
///
/// void main() async {
///   final controller = GreetingController();
///   unawaited(
///     serve(controller.router, 'localhost', 8080),
///   );
///   print('✅ Server listening on http://localhost:8080/');
///
///   print('🔍 Testing...');
///   (await (await HttpClient().get('localhost', 8080, '/eeqk')).close())
///       .transform(utf8.decoder)
///       .listen(print); // Hello, eeqk!
/// }
/// ```
library data_class_macro;

export 'src/controller.dart';
export 'src/http_verbs.dart';
