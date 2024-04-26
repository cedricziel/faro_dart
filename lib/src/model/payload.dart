import 'package:faro_dart/src/model/trace.dart';

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
  Trace? traces;

  Meta? meta;

  Payload(this.meta);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    map['events'] = events.map((v) => v.toJson()).toList();
    map['exceptions'] = exceptions.map((v) => v.toJson()).toList();
    map['logs'] = logs.map((v) => v.toJson()).toList();
    map['measurements'] = measurements.map((v) => v.toJson()).toList();
    map['traces'] = traces?.toJson();
    map['meta'] = meta?.toJson();

    return map;
  }

  Payload.empty();
}
