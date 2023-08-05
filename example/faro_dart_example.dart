import 'dart:io';

import 'package:faro_dart/faro_dart.dart';
import 'package:faro_dart/src/model/app.dart';
import 'package:faro_dart/src/model/event.dart';
import 'package:faro_dart/src/model/meta.dart';

Future<void> main() async {
  await Faro.init(
    (options) {
      var app = App("my-app", "0.0.1", "dev");

      options.collectorUrl = Uri.parse('https://your-collector.com/collector');
      options.meta = Meta(app: app);
    },
    // Init your App.
    appRunner: () async => await realMain(),
  );
}

realMain() async {
  // push a log message
  Faro.pushLog("delay");

  // push a measurement
  Faro.pushMeasurement("delay", 2);

  // push an event
  Faro.pushEvent(Event("cta", attributes: {
    "foo": "bar",
  }));

  Faro.pushView("home");

  // push an error
  try {
    throw 'foo!';
  } catch (e, s) {
    Faro.pushError(e, stackTrace: s);
  }

  // pause recording
  await Faro.pause();

  // unpause recording
  await Faro.unpause();

  // force draining the buffer
  await Faro.drain();
}
