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

## Tracking HTTP requests

In order to track http requests that your app is sending,
use the `FaroHttpClient` and it will automatically capture http requests as events.

```dart
// before
var client = HttpClient();
client.get("http://example.com");

// after
var client = FaroHttpClient();
client.get("http://example.com");
```

If you want to re-use an existing outer http client, you can wrap it:

```dart
var myClient = HttpClient();
var faroClient = FaroHttpClient(client: myClient);
client.get("http://example.com");
```