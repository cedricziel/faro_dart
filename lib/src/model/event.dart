class Event {
  String name = "";
  String domain = "flutter";
  dynamic attributes = {};
  DateTime timestamp = DateTime.now();

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

    return map;
  }
}
