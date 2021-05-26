import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/context/context_root.dart' as analyzer;
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_code_analysis/src/logger/log.dart';
import 'package:custom_code_analysis/src/utils/issue_map_util.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:custom_code_analysis/src/configs/rule_config.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:yaml/yaml.dart';

import '../model/analysis_options.dart';

// class TestPlugin extends ServerPlugin with FixesMixin, DartFixesMixin {

class CustomCodeAnalysisPlugin extends ServerPlugin {
  CustomCodeAnalysisPlugin(ResourceProvider provider) : super(provider);

  var _filesFromSetPriorityFilesRequest = <String>[];

  YamlMap _yamlMap;

  String _sourceUri;

  @override
  List<String> get fileGlobsToAnalyze => <String>['**/*.dart'];

  @override
  String get name => 'Custom Code Analysis';

  @override
  String get version => '1.0.0';

  @override
  bool isCompatibleWith(Version serverVersion) => true;

  @override
  void contentChanged(String path) {
    AnalysisDriverGeneric driver = super.driverForPath(path);
    driver.addFile(path);
  }

  @override
  AnalysisDriverGeneric createAnalysisDriver(plugin.ContextRoot contextRoot) {
    logUtil.info('createAnalysisDriver for: ${contextRoot.root}');
    _yamlMap = AnalysisOptionsProvider().getOptionsFromString(contextRoot.optionsFile);
    final analysisRoot = analyzer.ContextRoot(contextRoot.root, contextRoot.exclude, pathContext: resourceProvider.pathContext)
      ..optionsFilePath = contextRoot.optionsFile;

    final contextBuilder = ContextBuilder(resourceProvider, sdkManager, null)
      ..analysisDriverScheduler = analysisDriverScheduler
      ..byteStore = byteStore
      ..performanceLog = performanceLog;

    final dartDriver = contextBuilder.buildDriver(analysisRoot, null);
    _sourceUri = _getSourceUri(dartDriver);
    runZonedGuarded(
      () {
        dartDriver.results.listen((analysisResult) {
          logUtil.info('received analysis result from file: ${contextRoot.root}');
          _processResult(dartDriver, analysisResult);
        });
      },
      _onError,
    );

    return dartDriver;
  }

  void _onError(Object e, StackTrace stackTrace) {
    channel.sendNotification(plugin.PluginErrorParams(false, e.toString(), stackTrace.toString()).toNotification());
  }

  @override
  Future<plugin.AnalysisSetPriorityFilesResult> handleAnalysisSetPriorityFiles(plugin.AnalysisSetPriorityFilesParams parameters) async {
    _filesFromSetPriorityFilesRequest = parameters.files;
    _updatePriorityFiles();
    return plugin.AnalysisSetPriorityFilesResult();
  }

  void _updatePriorityFiles() {
    final filesToFullyResolve = {
      ..._filesFromSetPriorityFilesRequest,
      for (final driver2 in driverMap.values) ...(driver2 as AnalysisDriver).addedFiles,
    };
    final filesByDriver = <AnalysisDriverGeneric, List<String>>{};
    for (final file in filesToFullyResolve) {
      final contextRoot = contextRootContaining(file);
      if (contextRoot != null) {
        final driver = driverMap[contextRoot];
        filesByDriver.putIfAbsent(driver, () => <String>[]).add(file);
      }
    }
    filesByDriver.forEach((driver, files) => driver.priorityFiles = files);
  }

  String _getSourceUri(AnalysisDriver dartDriver) {
    String _uri;
    String _optionsFile = dartDriver.contextRoot.optionsFilePath;
    if (_optionsFile != null) {
      _uri = dartDriver.resourceProvider.pathContext.dirname(dartDriver.contextRoot.optionsFilePath);
    }
    return _uri;
  }

  void _processResult(AnalysisDriver driver, ResolvedUnitResult analysisResult) {
    try {
      if (analysisResult.unit != null && analysisResult.libraryElement != null) {
        String _fullName = analysisResult.unit.declaredElement.source.fullName;

        var globList = AnalysisOptions.fromYamlMap(_yamlMap).excludes.map((e) => Glob(p.join(_sourceUri, e))).toList();
        if (globList.any((glob) => glob.matches(_fullName))) {
          return;
        }

        List<Issue> issueList = [];
        for (final ruleId in AnalysisOptions.fromYamlMap(_yamlMap).rules) {
          var rule = findRuleById(ruleId);
          if (rule != null) {
            issueList.addAll(rule.check(analysisResult));
          }
        }
        if (issueList.isNotEmpty) {
          channel.sendNotification(
            plugin.AnalysisErrorsParams(
              analysisResult.path,
              issueList.map((issue) => codeIssueToAnalysisError(issue, analysisResult)).toList(),
            ).toNotification(),
          );
        } else {
          channel.sendNotification(plugin.AnalysisErrorsParams(analysisResult.path, []).toNotification());
        }
      } else {
        channel.sendNotification(plugin.AnalysisErrorsParams(analysisResult.path, []).toNotification());
      }
    } on Exception catch (e, stackTrace) {
      channel.sendNotification(plugin.PluginErrorParams(false, e.toString(), stackTrace.toString()).toNotification());
    }
  }

  @override
  Future<plugin.EditGetFixesResult> handleEditGetFixes(plugin.EditGetFixesParams parameters) async {
    try {
      final driver = driverForPath(parameters.file) as AnalysisDriver;
      final analysisResult = await driver.getResult2(parameters.file);

      List<AnalysisErrorFixes> errorFixes = [];
      for (final ruleId in AnalysisOptions.fromYamlMap(_yamlMap).rules) {
        var rule = findRuleById(ruleId);
        if (rule != null) {
          errorFixes.addAll(codeIssueToAnalysisErrorFixes(rule.check(analysisResult), analysisResult));
        }
      }

      return plugin.EditGetFixesResult(errorFixes);
    } on Exception catch (e, stackTrace) {
      channel.sendNotification(plugin.PluginErrorParams(false, e.toString(), stackTrace.toString()).toNotification());

      return plugin.EditGetFixesResult([]);
    }
  }
}
