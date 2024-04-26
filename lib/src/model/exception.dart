import 'package:stack_trace/stack_trace.dart';

class FaroException {
  late String type;
  late String value;
  FaroStacktrace? stackTrace;
  late DateTime timestamp;
  Map<String, String> context = {};

  FaroException.fromString(this.value, {StackTrace? incomingStackTrace}) {
    timestamp = DateTime.now();
    type = "Error";

    if (incomingStackTrace != null) {
      stackTrace = FaroStacktrace(incomingStackTrace);
    }
  }

  FaroException.fromException(Exception e, {StackTrace? incomingStackTrace})
      : value = e.toString() {
    timestamp = DateTime.now();
    type = "Exception";

    if (incomingStackTrace != null) {
      stackTrace = FaroStacktrace(incomingStackTrace);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "timestamp": timestamp.toUtc().toIso8601String(),
      "type": type,
      "value": value,
      "stacktrace": stackTrace?.toJson(),
    };
  }
}

class FaroStacktrace {
  final _frameRegex = RegExp(r'^\s*#', multiLine: true);
  List<FaroStackFrame> frames = [];

  FaroStacktrace(dynamic stackTrace) {
    // TODO: externalize
    var chain = _toChain(stackTrace);
    for (var trace in chain.traces) {
      for (var frame in trace.frames) {
        frames.add(FaroStackFrame.fromFrame(frame));
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "frames": frames.map((e) => e.toJson()).toList(),
    };
  }

  Chain _toChain(dynamic stackTrace) {
    if (stackTrace is Chain || stackTrace is Trace) {
      return Chain.forTrace(stackTrace);
    }

    if (stackTrace is StackTrace) {
      stackTrace = stackTrace.toString();
    }

    if (stackTrace is String) {
      // Remove headers (everything before the first line starting with '#').
      // *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
      // pid: 19226, tid: 6103134208, name io.flutter.ui
      // os: macos arch: arm64 comp: no sim: no
      // isolate_dso_base: 10fa20000, vm_dso_base: 10fa20000
      // isolate_instructions: 10fa27070, vm_instructions: 10fa21e20
      //     #00 abs 000000723d6346d7 _kDartIsolateSnapshotInstructions+0x1e26d7
      //     #01 abs 000000723d637527 _kDartIsolateSnapshotInstructions+0x1e5527

      final startOffset = _frameRegex.firstMatch(stackTrace)?.start ?? 0;
      return Chain.parse(
          startOffset == 0 ? stackTrace : stackTrace.substring(startOffset));
    }

    return Chain([]);
  }
}

class FaroStackFrame {
  String? function;
  String? module;
  String? filename;
  int? lineno;
  int? colno;

  Map<String, dynamic> toJson() {
    return {
      "function": function,
      "module": module,
      "filename": filename,
      "lineno": lineno,
      "colno": colno,
    };
  }

  FaroStackFrame.fromFrame(Frame frame) {
    function = frame.member;
    module = frame.package;
    filename = frame.uri.toString();

    colno = frame.column;
    lineno = frame.line;
  }
}
