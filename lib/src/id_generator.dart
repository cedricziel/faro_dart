// taken from https://github.com/Workiva/opentelemetry-dart/blob/815985946cd7c2d1be3423818d3d988a12183173/lib/src/sdk/trace/id_generator.dart
// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import 'dart:math';

class IdGenerator {
  static final Random _random = Random.secure();

  static List<int> _generateId(int byteLength) {
    final buffer = [];
    for (var i = 0; i < byteLength; i++) {
      buffer.add(_random.nextInt(256));
    }
    return buffer.cast<int>();
  }

  List<int> generateSpanId() => _generateId(8);

  List<int> generateTraceId() => _generateId(16);
}