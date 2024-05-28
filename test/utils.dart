import 'dart:convert';
import 'dart:io';

import 'package:matcher/expect.dart';
import 'package:matcher/src/expect/async_matcher.dart';

class ServerPort {
  static int _current = 8181;
  static int get unique => _current++;
}

Future<HttpClientResponse> get(int port, String path) async {
  return await (await HttpClient().get('localhost', port, path)).close();
}

Matcher ok(String result) => _OkMatcher(result);

class _OkMatcher extends AsyncMatcher {
  _OkMatcher(this.s);

  final String s;

  @override
  dynamic matchAsync(dynamic item) {
    if (item is! HttpClientResponse) return 'is not a HttpClientResponse';
    if (item.statusCode != 200)
      return 'did not return 200 OK (was ${item.statusCode} ${item.reasonPhrase})';

    return Future(
      () async {
        final bodyString = await item.transform(utf8.decoder).join();
        final matches = equalsIgnoringWhitespace(s).matches(bodyString, {});

        if (!matches) return 'did not return $s (was $bodyString)';
      },
    );
  }

  @override
  Description describe(Description description) => description;
}
