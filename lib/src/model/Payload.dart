import 'Event.dart';
import 'Meta.dart';

class Payload {
  List<Event> events = [];
  Meta? meta;

  Payload(this.meta) {
    events = [];
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

    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
    return map;
  }

}