class Log {
  String message;
  late DateTime timestamp;

  Log(this.message) {
    timestamp = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "timestamp": timestamp.toUtc().toIso8601String(),
    };
  }
}
