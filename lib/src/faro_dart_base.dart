import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:faro_dart/src/model/event.dart';
import 'package:faro_dart/src/model/exception.dart';
import 'package:faro_dart/src/model/meta.dart';
import 'package:faro_dart/src/model/payload.dart';
import 'package:faro_dart/src/model/view.dart';
import 'package:synchronized/synchronized.dart';

import 'model/log.dart';
import 'model/measurement.dart';

class Faro {
  static const String userAgent = "faro-dart/0.1";
  static const interval = Duration(milliseconds: 100);

  Lock lock = Lock();

  Uri endpoint;

  // app meta
  Meta meta;
  HttpClient httpClient;

  late Timer ticker;
  late Payload _payload;

  Faro(this.endpoint, this.meta, this.httpClient) {
    ticker = Timer.periodic(interval, (Timer t) => _tick);
    _payload = Payload(meta);
  }

  init() async {
    await pushEvent(Event("session_started"));
  }

  // stop ticking after one more :)
  pause() async {
    lock.synchronized(() => _tick);

    ticker.cancel();
  }

  unpause() async {
    ticker = Timer.periodic(interval, (Timer t) => _tick);
  }

  void close() {
    httpClient.close();
  }

  pushLog(String message) {
    if (!ticker.isActive) {
      return;
    }

    _payload.logs.add(Log(message));
  }

  pushEvent(Event event) async {
    if (!ticker.isActive) {
      return;
    }

    _payload.events.add(event);
  }

  pushMeasurement(String name, num value) {
    if (!ticker.isActive) {
      return;
    }

    _payload.measurements.add(Measurement(name, value));
  }

  pushPayload(Payload payload) {}

  pushView(String view) {
    if (!ticker.isActive) {
      return;
    }

    lock.synchronized(() {
      _payload.meta?.view = View(view);
      _payload.events.add(Event('view_changed', attributes: {
        'name': view,
      }));
    });
  }

  drain() async {
    await _tick();
  }

  _tick() async {
    await lock.synchronized(() async {
      // bail if no events
      if (_payload.events.isEmpty) {
        return;
      }

      try {
        HttpClientRequest req = await httpClient.postUrl(endpoint);
        req.headers.add("User-Agent", userAgent);
        req.headers.add("Content-Type", "application/json");
        var json = jsonEncode(_payload.toJson());
        req.write(json);

        await req.close();
      } finally {
        _payload = Payload(meta);
      }
    });
  }

  void pushError(Object error, {StackTrace? stackTrace}) {
    if (error is String) {
      lock.synchronized(() {
        _payload.exceptions
            .add(FaroException.fromString(error, stackTrace: stackTrace));
      });
    }
  }
}
