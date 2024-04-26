import 'dart:io';

import 'package:faro_dart/faro_dart.dart';
import 'package:faro_dart/src/http/faro_tracing_http_client.dart';
import 'package:http/http.dart';

/// Taking inspiration from Sentry once more - they are effectively decorating
/// clients in clients to enable observability. Great pattern that enables
/// composability.
class FaroHttpClient extends BaseClient {
  late FaroTracingHttpClient _client;
  String serviceName;

  FaroHttpClient(this.serviceName, {Client? client}) {
    if (client != null) {
      _client = FaroTracingHttpClient(serviceName, client: client);
    } else {
      _client = FaroTracingHttpClient(serviceName, client: Client());
    }
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    Map<String, String> attributes = {
      "http.request.method": request.method,
      "http.url": request.url.toString(),
      "url.full": request.url.toString(),
      "server.address": request.url.host,
      "server.port": request.url.port.toString(),
    };

    try {
      final response = await _client.send(request);

      attributes["http.response.status_code"] = response.statusCode.toString();

      return response;
    } catch (_) {
      attributes['failed'] = "true";
      rethrow;
    } finally {
      var event = Event('faro.http', attributes: attributes);
      if (_client.traceId != "") {
        event.trace.addAll({"trace_id": _client.traceId});
      }
      if (_client.spanId != "") {
        event.trace.addAll({"span_id": _client.spanId});
      }

      Faro.pushEvent(event);
    }
  }
}