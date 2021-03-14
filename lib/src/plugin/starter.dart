import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:custom_code_analysis/src/plugin/plugin.dart';
import '../logger/log.dart';

void start(List<String> args, SendPort sendPort) {
  logUtil.info('-----------analysis server restarted-------------');
  ServerPluginStarter(TestPlugin(PhysicalResourceProvider.INSTANCE)).start(sendPort);
}
