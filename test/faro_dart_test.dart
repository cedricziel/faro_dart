import 'dart:io';

import 'package:faro_dart/faro_dart.dart';
import 'package:faro_dart/src/model/Meta.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final awesome = Faro(Uri.parse(""), Meta(), HttpClient());

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(awesome.lock, isNotNull);
    });
  });
}
