import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:faro_dart/src/faro_settings.dart';
import 'package:faro_dart/src/model/event.dart';
import 'package:faro_dart/src/model/exception.dart';
import 'package:faro_dart/src/model/payload.dart';
import 'package:faro_dart/src/model/view.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import 'model/log.dart';
import 'model/measurement.dart';

typedef SettingsConfiguration = FutureOr<void> Function(FaroSettings);

typedef AppRunner = FutureOr<void> Function();

class Faro {
  static const String userAgent = "faro-dart/0.1";
  static const interval = Duration(milliseconds: 100);

  Lock lock = Lock();
  FaroSettings currentSettings = FaroSettings();
  Timer ticker = Timer(interval, () {});
  Payload _payload = Payload.empty();
  bool initialized = false;

  static Faro? _instance;

  static Faro get instance {
    _instance ??= Faro._();
    return _instance!;
  }

  Faro._();

  static Future<void> init(SettingsConfiguration settingsConfiguration,
      {AppRunner? appRunner, @internal FaroSettings? settings}) async {
    final faroSettings = settings ?? FaroSettings();

    try {
      final config = settingsConfiguration(faroSettings);
      if (config is Future) {
        await config;
      }
    } catch (exception) {
      // do nothing
    }

    if (faroSettings.collectorUrl == null) {
      throw ArgumentError('`faroSettings.collectorUrl` has to be set');
    }

    _init(faroSettings, appRunner);
  }

  static _init(FaroSettings settings, AppRunner? appRunner) async {
    instance.initialized = true;
    instance.currentSettings = settings;
    instance.ticker = Timer.periodic(interval, (Timer t) => Faro.tick());

    await Faro.pushEvent(Event("session_started"));

    instance.initialized = true;
    instance.currentSettings = settings;

    if (appRunner != null) {
      await appRunner();
    }
  }

  // stop ticking after one more :)
  static pause() async {
    if (!instance.initialized) {
      return;
    }

    instance.lock.synchronized(() => tick);

    instance.ticker.cancel();
  }

  static unpause() async {
    if (!instance.initialized) {
      return;
    }

    instance.ticker = Timer.periodic(interval, (Timer t) => tick);
  }

  void close() {
    currentSettings.httpClient.close();
  }

  static pushLog(String message) {
    if (!instance.initialized) {
      return;
    }

    if (!instance.ticker.isActive) {
      return;
    }

    instance._payload.logs.add(Log(message));
  }

  static pushEvent(Event event) async {
    if (!instance.initialized) {
      return;
    }

    if (!instance.ticker.isActive) {
      return;
    }

    instance._payload.events.add(event);
  }

  static pushMeasurement(String name, num value) {
    if (!instance.initialized) {
      return;
    }

    if (!instance.ticker.isActive) {
      return;
    }

    instance._payload.measurements.add(Measurement(name, value));
  }

  static pushView(String view) {
    if (!instance.initialized) {
      return;
    }

    if (!instance.ticker.isActive) {
      return;
    }

    instance.lock.synchronized(() {
      instance._payload.meta?.view = View(view);
      instance._payload.events.add(Event('view_changed', attributes: {
        'name': view,
      }));
    });
  }

  static drain() async {
    await Faro.tick();
  }

  @internal
  static tick() async {
    if (!instance.initialized) {
      return;
    }

    await instance.lock.synchronized(() async {
      // bail if no events
      if (instance._payload.events.isEmpty) {
        return;
      }

      try {
        Uri url = instance.currentSettings.collectorUrl!;
        HttpClientRequest req =
            await instance.currentSettings.httpClient.postUrl(url);
        req.headers.add("User-Agent", userAgent);
        req.headers.add("Content-Type", "application/json");
        var json = jsonEncode(instance._payload.toJson());
        req.write(json);

        await req.close();
      } finally {
        instance._payload = Payload(instance.currentSettings.meta);
      }
    });
  }

  static void pushError(Object error, {StackTrace? stackTrace}) {
    if (error is String) {
      instance.lock.synchronized(() {
        instance._payload.exceptions
            .add(FaroException.fromString(error, stackTrace: stackTrace));
      });
    }
  }
}
