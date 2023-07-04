class Event {
  String name = "";
  String domain = "foo";
  dynamic attributes = {};
  String timestamp = DateTime.now().toIso8601String();

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
    map['timestamp'] = timestamp;

    return map;
  }
}
