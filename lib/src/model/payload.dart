import 'event.dart';
import 'exception.dart';
import 'log.dart';
import 'measurement.dart';
import 'meta.dart';

class Payload {
  List<Event> events = [];
  List<FaroException> exceptions = [];
  List<Log> logs = [];
  List<Measurement> measurements = [];

  Meta? meta;

  Payload(this.meta) {
    events = [];
    measurements = [];
  }

  Payload.fromJson(dynamic json) {
    if (json['events'] != null) {
      events = [];
      json['events'].forEach((v) {
        events.add(Event.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    map['events'] = events.map((v) => v.toJson()).toList();
    map['exceptions'] = exceptions.map((v) => v.toJson()).toList();
    map['logs'] = logs.map((v) => v.toJson()).toList();
    map['measurements'] = measurements.map((v) => v.toJson()).toList();

    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
    return map;
  }

  Payload.empty();
}
