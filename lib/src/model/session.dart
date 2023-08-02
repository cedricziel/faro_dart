import 'package:uuid/uuid.dart';

class Session {
  late String id;

  Session() {
    id = Uuid().v4().toString();
  }

  Session.resume(String id) {
    id = id;
  }

  Session.fromJson(dynamic json) {
    id = json['id'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    return map;
  }
}
