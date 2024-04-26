import '../util.dart';

class Session {
  late String id;
  Map<String, String> attributes = {};

  Session() {
    id = getRandomString(10);
  }

  Session.resume(String id) {
    id = id;
  }

  void setAttribute(String key, String value) {
    attributes[key] = value;
  }

  Session.fromJson(dynamic json) {
    id = json['id'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['attributes'] = attributes;
    return map;
  }
}
