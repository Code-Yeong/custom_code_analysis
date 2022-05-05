import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:custom_code_analysis/src/plugin/plugin.dart';
import 'package:custom_code_analysis/src/utils/checker_utils.dart';
import '../logger/log.dart';

void start(List<String> args, SendPort sendPort) {
  clearAllIdRecords();
  logUtil.info('-----------analysis server restarted-------------');
  ServerPluginStarter(CustomCodeAnalysisPlugin(PhysicalResourceProvider.INSTANCE)).start(sendPort);
}
