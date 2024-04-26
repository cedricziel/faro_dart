import 'package:faro_dart/faro_dart.dart';
import 'package:faro_dart/src/model/trace.dart';
import 'package:http/http.dart';
import 'package:convert/convert.dart';

class FaroTracingHttpClient extends BaseClient {
  late Client _client;
  String serviceName;
  String traceId = "";
  String spanId = "";

  FaroTracingHttpClient(this.serviceName, {Client? client}) {
    _client = client ?? Client();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    Trace trace = Trace.empty();
    trace.resourceSpans[0].resource = Resource.defaultResource("dart-app");
    Span span = trace.httpClientSpan(request);

    try {
      final response = await _client.send(request);

      span.addAttribute("http.status_code", AttributeValue.integer(response.statusCode));

      return response;
    } catch (_) {
      span.status = SpanStatus.error;

      rethrow;
    } finally {
      span.end();
      trace.addSpan(span);

      traceId = hex.encode(trace.traceId);
      spanId = hex.encode(span.spanId);

      Faro.pushTrace(trace);
    }
  }
}