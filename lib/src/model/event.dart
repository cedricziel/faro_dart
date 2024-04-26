class Event {
  String name = "";
  String domain = "flutter";
  dynamic attributes = {};
  DateTime timestamp = DateTime.now();
  Map<String, String> trace = {};

  Event(this.name, {this.attributes});

  Event.fromJson(dynamic json) {
    name = json['name'];
    domain = json['domain'];
    attributes = json['attributes'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    map['name'] = name;
    map['domain'] = domain;
    map['attributes'] = attributes;
    map['timestamp'] = timestamp.toUtc().toIso8601String();

    if (!trace.isEmpty) {
      map['trace'] = {};
      if (trace.containsKey("trace_id")) {
        map['trace']['trace_id'] = trace['trace_id'];
      }
      if (trace.containsKey("span_id")) {
        map['trace']['span_id'] = trace['span_id'];
      }
    }

    return map;
  }
}
