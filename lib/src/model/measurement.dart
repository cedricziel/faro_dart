class Measurement {
  late DateTime timestamp;
  late Map<String, num> values = {};

  Measurement(String name, num value) {
    timestamp = DateTime.now();
    values = {name: value};
  }

  Map<String, dynamic> toJson() {
    return {
      "timestamp": timestamp.toUtc().toIso8601String(),
      "trace": null,
      "values": values,
    };
  }
}
