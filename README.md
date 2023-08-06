# faro_dart

Grafana Faro, but for Dart (and flutter).

## Disclaimer

This project is neither endorsed nor supported by Grafana Labs.

## Usage

See `./example/faro_dart_example.dart`

```dart
Future<void> main() async {
  await Faro.init(
          (options) {
        var app = App("my-app", "0.0.1", "dev");

        options.collectorUrl = Uri.parse('https://your-collector.com/collector');
        options.meta = Meta(app: app);
      }
  );

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
```
