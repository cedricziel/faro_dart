class View {
  String? name;

  View(this.name);

  View.fromJson(dynamic json) {
    name = json['name'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    map['name'] = name;

    return map;
  }
}
