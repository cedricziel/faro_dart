import 'dart:io';

import 'package:faro_dart/faro_dart.dart';
import 'package:faro_dart/src/model/app.dart';
import 'package:faro_dart/src/model/meta.dart';

void main() {
  var app = App("my-app", "0.0.1", "dev");
  var meta = Meta(app: app);
  var faro = Faro(Uri.parse("https://foo/bar"), meta, HttpClient());

  // init emits a session_start event
  faro.init();

  // pause recording
  // unpause recording
  faro.unpause();
}
