import 'dart:io';

import 'package:faro_dart/faro_dart.dart';
import 'package:faro_dart/src/model/App.dart';
import 'package:faro_dart/src/model/Meta.dart';

void main() {
  var app = App("my-app", "0.0.1", "dev");
  var meta = Meta(app: app);
  var awesome = Faro(Uri.parse("https://foo/bar"), meta, HttpClient());

  awesome.init();
}
