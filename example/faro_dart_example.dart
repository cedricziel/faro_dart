import 'dart:io';

import 'package:faro_dart/faro_dart.dart';
import 'package:faro_dart/src/model/app.dart';
import 'package:faro_dart/src/model/event.dart';
import 'package:faro_dart/src/model/meta.dart';

Future<void> main() async {
  var app = App("my-app", "0.0.1", "dev");
  var meta = Meta(app: app);
  var faro = Faro(Uri.parse("https://foo/bar"), meta, HttpClient());

  // init emits a session_start event
  faro.init();

  // push a log message
  faro.pushLog("delay");

  // push a measurement
  faro.pushMeasurement("delay", 2);

  // push an event
  faro.pushEvent(Event("cta", attributes: {
    "foo": "bar",
  }));

  faro.pushView("home");

  // push an error
  try {
    throw 'foo!';
  } catch (e, s) {
    faro.pushError(e, stackTrace: s);
  }

  // pause recording
  await faro.pause();

  // unpause recording
  await faro.unpause();

  // force draining the buffer
  await faro.drain();
}
