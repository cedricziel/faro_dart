import 'dart:convert';

class Measurement {
  late DateTime timestamp;
  late Map<String, String> values = {};

  Measurement(String name, String value) {
    timestamp = DateTime.now();
    values = {name: value};
  }

  Map<String, dynamic> toJson() {
    return {
      "timestamp": timestamp.toIso8601String(),
      "trace": null,
      "values": values,
    };
  }
}
