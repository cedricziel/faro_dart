import 'package:convert/convert.dart';

import 'package:faro_dart/src/id_generator.dart';
import 'package:http/src/base_request.dart';

class AttributeValue {
  String stringValue = "";
  int intValue = -999;

  AttributeValue.string(this.stringValue);

  AttributeValue.integer(this.intValue);

  Map<String, dynamic> toJson() {
    return {
      if (stringValue != "") "stringValue": stringValue,
      if (intValue != -999) "intValue": intValue,
    };
  }
}

class Resource {
  Map<String, AttributeValue> attributes = {};
  int droppedAttributesCount = 0;

  Resource.defaultResource(String serviceName) : attributes = {
    "service.name": AttributeValue.string(serviceName),
    "telemetry.sdk.language": AttributeValue.string("dart"),
    "telemetry.sdk.name": AttributeValue.string("faro_flutter"),
    "telemetry.sdk.version": AttributeValue.string("0.0.1"),
  };

  Resource.empty() : attributes = {};

  Map<String, dynamic> toJson() {
    var returnValue = {
      "attributes": {},
    };

    attributes.forEach((k, v) {
      returnValue[k] = v.toJson();
    });

    return returnValue;
  }
}

enum SpanKind {kindClient, kindServer, kindProducer, kindConsumer, kindInternal}
enum SpanStatus {unset, ok, error}

class InstrumentationLibrarySpan {
  List<Span> spans = [];

  InstrumentationLibrarySpan(Span span);

  Map<String, dynamic> toJson() {
    var returnValue = {
      "spans": []
    };

    for (var element in spans) {
      returnValue["spans"]?.add(element.toJson());
    }

    return returnValue;
  }
}

class Span {
  List<int> traceId;
  List<int> spanId;
  List<int>? parentSpanId;
  String name;
  SpanKind kind = SpanKind.kindInternal;

  DateTime startTimeUnixNano;
  late DateTime endTimeUnixNano;

  Map <String,AttributeValue> attributes = {};
  int droppedAttributesCount = 0;

  List<dynamic> events = [];
  int droppedEventsCount = 0;

  SpanStatus status = SpanStatus.unset;

  List<dynamic> links = [];

  bool _ended = false;

  Span(this.name, {required Trace trace}): traceId = trace.traceId,
        spanId = Trace.idGenerator.generateSpanId(),
        startTimeUnixNano = DateTime.now();

  Map <String, dynamic> toJson() {
    if (!_ended) {
      throw 'Close span before encoding!';
    }

    var _attributes = {};
    attributes.forEach((key, value) {
      _attributes[key] = value.toJson();
    });

    return {
      "traceId": hex.encode(traceId),
      "spanId": hex.encode(spanId),
      if (parentSpanId != null) "parentSpanId": hex.encode(parentSpanId!),
      "name": name,
      "kind": kind,
      "startTimeUnixNano": startTimeUnixNano.toUtc().microsecondsSinceEpoch * 1000,
      "endTimeUnixNano": endTimeUnixNano.toUtc().microsecondsSinceEpoch * 1000,
      "attributes": _attributes,
      "droppedAttributesCount": droppedAttributesCount,
      "events": [],
      "droppedEventsCount": droppedEventsCount,
      "status": {"code": status.index}
    };
  }

  void end() {
    if (!_ended) {
      endTimeUnixNano = DateTime.now();
      _ended = true;
    }
  }

  void addAttribute(String key, AttributeValue attributeValue) {
    attributes[key] =  attributeValue;
  }
}

class ResourceSpan {
  Resource resource = Resource.empty();
  List<InstrumentationLibrarySpan> instrumentationLibrarySpans = [];

  ResourceSpan({required this.resource});

  Map<String, dynamic> toJson() {
    var returnValue = {
      "resource": resource.toJson(),
      "instrumentationLibrarySpans": [],
    };

    for (var span in instrumentationLibrarySpans) {
      (returnValue["instrumentationLibrarySpans"] as List).add(span.toJson());
    }

    return returnValue;
  }
}

class Trace {
  static IdGenerator idGenerator = IdGenerator();

  List<int> traceId;
  List<ResourceSpan> resourceSpans = [ResourceSpan(resource: Resource.empty())];

  Trace.empty() : traceId = idGenerator.generateTraceId();

  Map<String, dynamic> toJson() {
    var returnValue = {
      "resourceSpans": [],
    };

    for (var value in resourceSpans) {
      returnValue['resourceSpans']?.add(value.toJson());
    }

    return returnValue;
  }

  Span httpClientSpan(BaseRequest request) {
    var span = Span("${request.method} ${request.url.path}", trace: this);
    span.kind = SpanKind.kindClient;
    span.attributes.addAll({
      "http.url": AttributeValue.string(request.url.toString()),
    });

    return addSpan(span);
  }

  Span addSpan(Span span) {
    resourceSpans[0].instrumentationLibrarySpans.addAll([InstrumentationLibrarySpan(span)]);

    return span;
  }
}