import 'dart:async';
import 'dart:io';

import 'package:faro_dart/src/model/event.dart';
import 'package:faro_dart/src/model/meta.dart';
import 'package:faro_dart/src/model/sayload.dart';
import 'package:faro_dart/src/model/view.dart';
import 'package:synchronized/synchronized.dart';

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
    await pushEvent(Event("session_started", attributes: {"cool": "totally"}));
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

  pushLogs() {}

  pushEvent(Event event) async {
    _payload.events.add(event);
  }

  pushMeasurement(String name, double value, Map<String, String>? attributes) {}

  pushPayload(Payload payload) {}

  pushView(String view) {
    lock.synchronized(() => _payload.meta?.view = View(view));
  }

  _tick() {
    lock.synchronized(() async {
      // bail if no events
      if (_payload.events.isEmpty) {
        return;
      }

      try {
        HttpClientRequest req = await httpClient.postUrl(endpoint);
        req.headers.add("User-Agent", userAgent);
        req.write(_payload.toJson());

        await req.close();
      } finally {
        _payload = Payload(meta);
      }
    });
  }
}
