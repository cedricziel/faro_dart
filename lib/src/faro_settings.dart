import 'dart:io';

import 'model/meta.dart';

class FaroSettings {
  Uri? collectorUrl;
  Meta meta = Meta();
  HttpClient httpClient = HttpClient();
}
