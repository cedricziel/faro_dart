class Session {
  String? id;

  Session(this.id);

  Session.fromJson(dynamic json) {
    id = json['id'] ?? "";
  }


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    return map;
  }
}