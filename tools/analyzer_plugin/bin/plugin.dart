import 'dart:isolate';

import 'package:custom_code_analysis/src/plugin/starter.dart';

void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}
