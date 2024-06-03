# shelf_router_macro

[![build](https://github.com/eEQK/shelf_router_macro/actions/workflows/main.yaml/badge.svg)](https://github.com/eEQK/shelf_router_macro/actions/workflows/main.yaml)
[![pub package](https://img.shields.io/pub/v/shelf_router_macro.svg)](https://pub.dev/packages/shelf_router_macro)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

**🚧 Experimental** support for [shelf_router](https://pub.dev/packages/shelf_router)
using [macros](https://dart.dev/language/macros).

## 🌟 Features

* ✨ Route declarations
* ✨ Route parameters
* ✨ Async routes
* ✨ Lightweight - no additional dependencies beyond `shelf_router`
* 🖊️  _In Progress_ Intuitive - custom return types
* 🖊️  _In Progress_ Minimalistic - no need to specify `Request`/`Response`, just return response
  body

## 🧑‍💻 Example

```dart
import 'package:data_class_macro/data_class_macro.dart';

@Controller()
class GreetingController {
  @Get('/<name>')
  Response greetingByName(Request request, String name) {
    return Response.ok('Hello, $name!');
  }

  @Get('/wave')
  Future<String> wave() async {
    await Future.delayed(const Duration(seconds: 1));
    return '_o/';
  }
}

void main() async {
  final controller = GreetingController();
  unawaited(
    serve(controller.router, 'localhost', 8080),
  );
  print('✅ Server listening on http://localhost:8080/');

  print('🔍 Testing...');
  (await (await HttpClient().get('localhost', 8080, '/eeqk')).close())
      .transform(utf8.decoder)
      .listen(print); // Hello, eeqk!
}
```

## 🚀 Quick Start

> [!IMPORTANT]
> This package requires Dart SDK >= 3.5.0-164.0.dev

1. Download Dart from `dev` or `master` channel
    * [Dart SDK archive](https://dart.dev/get-dart/archive#dev-channel)
    * [dvm: Dart Version Manager](https://github.com/cbracken/dvm)
    * Alternatively, you can simply switch to flutter master channel:
   ```sh
   $ flutter channel master
   ```

2. Add `package:shelf_router_macro` to your `pubspec.yaml`
   ```sh
   $ dart pub add shelf_router_macro
   ```

3. Enable experimental macros in `analysis_options.yaml`
   ```yaml
   analyzer:
     enable-experiment:
       - macros
   ```

4. Use annotations provided by this library (see above example).

5. Run it
   ```sh
   $ dart --enable-experiment=macros run lib/main.dart
   ```


