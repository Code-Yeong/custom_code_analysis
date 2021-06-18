import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:custom_code_analysis/src/plugin/plugin.dart';
import '../logger/log.dart';
List<String> existIdList = [];
void start(List<String> args, SendPort sendPort) {
  existIdList.clear();
  logUtil.info('-----------analysis server restarted-------------');
  ServerPluginStarter(CustomCodeAnalysisPlugin(PhysicalResourceProvider.INSTANCE)).start(sendPort);
}
