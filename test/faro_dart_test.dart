import 'dart:convert';
import 'dart:io';

import 'package:faro_dart/faro_dart.dart';
import 'package:faro_dart/src/model/app.dart';
import 'package:faro_dart/src/model/event.dart';
import 'package:faro_dart/src/model/meta.dart';
import 'package:faro_dart/src/model/session.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_test_handler/shelf_test_handler.dart';
import 'package:test/test.dart';

void main() {
  group('Flutter mock server', () {
    late ShelfTestServer server;

    setUp(() async {
      server = await ShelfTestServer.create();
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test('should return correct port and url', () {
      expect(server.url.port, isNotNull);
    });

    test('test end2end', () async {
      server.handler.expect("POST", "/collect/foo-bar", (request) async {
        // This handles the GET /token request.
        var body = jsonDecode(await request.readAsString());

        // Test Events
        expect(body, contains("events"));
        expect(body['events'][0], containsPair("name", "custom"));
        expect(body['events'][0], contains("attributes"));
        expect(body['events'][0]['attributes'], containsPair("foo", "bar"));

        // Test logs
        expect(body, contains("logs"));
        expect(body['logs'][0], containsPair("message", 'my-log'));

        // Test measurements
        expect(body, contains("measurements"));
        expect(body['measurements'][0], contains("values"));
        expect(
            body['measurements'][0]['values'], containsPair('my-measure', 2));

        // Test exceptions
        expect(body, contains("exceptions"));
        expect(body['exceptions'][0], contains("stacktrace"));
        expect(body['exceptions'][0]['stacktrace'], contains('frames'));
        expect(body['exceptions'][0]['stacktrace']['frames'][2],
            containsPair('function', 'Declarer.test.<fn>'));
        expect(body['exceptions'][0]['stacktrace']['frames'][2],
            containsPair('module', 'test_api'));
        expect(body['exceptions'][0]['stacktrace']['frames'][2],
            containsPair('filename', 'package:test_api/src/backend/declarer.dart'));
        expect(body['exceptions'][0]['stacktrace']['frames'][2],
            containsPair('lineno', 213));
        expect(body['exceptions'][0]['stacktrace']['frames'][2],
            containsPair('colno', 7));

        return shelf.Response.ok("",
            headers: {"content-type": "application/json"});
      });

      var url = Uri.parse("${server.url}/collect/foo-bar");
      var meta = Meta(
        app: App("foo", "0.0.1", "dev"),
        session: Session(),
      );

      final faro = Faro(url, meta, HttpClient());
      faro.pushEvent(Event('custom', attributes: {
        'foo': 'bar',
      }));

      faro.pushMeasurement('my-measure', 2);

      faro.pushLog('my-log');

      faro.pushView("home");

      try {
        throw 'foo!';
      } catch (e, s) {
        faro.pushError(e, stackTrace: s);
      }

      await faro.drain();
    });
  });
}
