import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/analysis_options/analysis_options_provider.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/context/context_root.dart' as analyzer;
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:custom_code_analysis/src/configs/rule_config.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/utils/yaml_utils.dart';

import '../logger/log.dart';
import '../model/analysis_options.dart';
import '../model/rule.dart';

// class TestPlugin extends ServerPlugin with FixesMixin, DartFixesMixin {
class TestPlugin extends ServerPlugin {
  TestPlugin(ResourceProvider provider) : super(provider);

  // static const excludedFolders = ['.dart_tool/**'];

  var _filesFromSetPriorityFilesRequest = <String>[];

  AnalysisOptions _options;

  String _sourceUri;

  @override
  List<String> get fileGlobsToAnalyze => <String>['**/*.dart'];

  @override
  String get name => 'Test Plugin';

  @override
  String get version => '0.0.8';

  @override
  bool isCompatibleWith(Version serverVersion) => true;

  @override
  void contentChanged(String path) {
    AnalysisDriverGeneric driver = super.driverForPath(path);
    driver.addFile(path);
  }

  @override
  AnalysisDriverGeneric createAnalysisDriver(plugin.ContextRoot contextRoot) {
    // logUtil.info('root = ${contextRoot.root}');
    // logUtil.info('exclude = ${contextRoot.exclude}');
    // logUtil.info('pathContext = ${resourceProvider.pathContext}');
    final analysisRoot = analyzer.ContextRoot(contextRoot.root, contextRoot.exclude, pathContext: resourceProvider.pathContext)
      ..optionsFilePath = contextRoot.optionsFile;

    final contextBuilder = ContextBuilder(resourceProvider, sdkManager, null)
      ..analysisDriverScheduler = analysisDriverScheduler
      ..byteStore = byteStore
      ..performanceLog = performanceLog
      ..fileContentOverlay = fileContentOverlay;

    final dartDriver = contextBuilder.buildDriver(analysisRoot);
    _options = _readOptions(dartDriver);
    _sourceUri = _getSourceUri(dartDriver);
    runZonedGuarded(() {
      dartDriver.results.listen((analysisResult) {
        _processResult(dartDriver, analysisResult);
        // logUtil.info('analysisResult= ${analysisResult.errors.first.toString()}');
      });
    }, (e, stackTrace) {
      channel.sendNotification(plugin.PluginErrorParams(false, e.toString(), stackTrace.toString()).toNotification());
    });

    return dartDriver;
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

  AnalysisOptions _readOptions(AnalysisDriver driver) {
    if (driver?.contextRoot?.optionsFilePath?.isNotEmpty ?? false) {
      final file = resourceProvider.getFile(driver.contextRoot.optionsFilePath);
      if (file.exists) {
        var map = yamlMapToDartMap(AnalysisOptionsProvider(driver.sourceFactory).getOptionsFromFile(file));
        // logUtil.info('yamlConfig = ${map}');
        try {
          AnalysisOptions options = AnalysisOptions.fromMap(map);
          // logUtil.info('return options = $options');
          return options;
        } catch (e) {
          logUtil.info('error = $e');
        }
      }
    }

    return null;
  }

  void _processResult(AnalysisDriver driver, ResolvedUnitResult analysisResult) {
    try {
      if (analysisResult.unit != null && analysisResult.libraryElement != null) {
        String _fullName = analysisResult.unit.declaredElement.source.fullName;

        var globList = _options.excludes.map((e) => Glob(p.join(_sourceUri, e))).toList();
        // for (final v in globList) {
        //   logUtil.info('匹配：$v, ${v.matches(_fullName)}, $_fullName');
        // }
        if (globList.any((glob) => glob.matches(_fullName))) {
          // logUtil.info('命中：$_fullName');
          return;
        }

        List<ErrorIssue> errorList = [];
        for (final ruleId in _options.rules) {
          var ruleType = ruleConfigs[ruleId];
          if (ruleType != null) {
            errorList.addAll(ruleType(analysisResult.unit, analysisResult).errors());
          }
        }
        if (errorList.isNotEmpty) {
          channel.sendNotification(
            plugin.AnalysisErrorsParams(
              analysisResult.path,
              errorList.map((e) => e.error).toList(),
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
      final analysisResult = await driver.getResult(parameters.file);
      List<ErrorIssue> errorList = [];
      List<Rule> ruleList = [];
      for (final ruleId in _options.rules) {
        // logUtil.info('ruleTypesssruleId = $ruleId');
        var ruleType = ruleConfigs[ruleId];
        // logUtil.info('ruleTypesss = $ruleType');
        if (ruleType != null) {
          errorList.addAll(ruleType(analysisResult.unit, analysisResult).errors());
          ruleList.add(ruleType(analysisResult.unit, analysisResult));
        }
      }
      // logUtil.info('fixErrlist = $errorList');
      // final parametersMissing = ClickableWidgetIdMissing(analysisResult.unit, analysisResult);
      // var errorList = parametersMissing.errors();
      var _fixes = errorList
          .where((error) {
            // logUtil.info('fixesIsNull = ${error.fixes}, isTrue = ${error.fixes == null}');
            return error.replacement != null &&
                error.error.location.file == parameters.file &&
                error.error.location.offset + error.error.location.length >= parameters.offset &&
                error.error.location.offset <= parameters.offset &&
                error.fixes != null;
          })
          .map((e) => e.fixes)
          .toList();
      // logUtil.info('fixErrlist2 = $_fixes');
      // final fixes = _fixes.where((fix) => true).toList();

      return plugin.EditGetFixesResult(_fixes);
    } on Exception catch (e, stackTrace) {
      channel.sendNotification(plugin.PluginErrorParams(false, e.toString(), stackTrace.toString()).toNotification());

      return plugin.EditGetFixesResult([]);
    }
  }
}
