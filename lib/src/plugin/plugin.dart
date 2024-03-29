import 'dart:async';
import 'dart:io' as io;

import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/analysis/byte_store.dart';
import 'package:analyzer/src/dart/analysis/context_builder.dart';

// import 'package:analyzer/src/context/context_root.dart' as analyzer;
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/dart/analysis/file_byte_store.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_code_analysis/src/configs/rule_config.dart';
import 'package:custom_code_analysis/src/logger/log.dart';
import 'package:custom_code_analysis/src/model/analysis_options.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/utils/issue_map_util.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../model/analysis_options.dart';
// class TestPlugin extends ServerPlugin with FixesMixin, DartFixesMixin {

ByteStore createByteStore(PhysicalResourceProvider resourceProvider) {
  const miB = 1024 * 1024 /*1 MiB*/;
  const giB = 1024 * 1024 * 1024 /*1 GiB*/;

  const memoryCacheSize = miB * 128;

  final stateLocation = resourceProvider.getStateLocation('.dart-code-metrics');
  if (stateLocation != null) {
    return MemoryCachingByteStore(
      EvictingFileByteStore(stateLocation.path, giB),
      memoryCacheSize,
    );
  }

  return MemoryCachingByteStore(NullByteStore(), memoryCacheSize);
}

class CustomCodeAnalysisPlugin extends ServerPlugin {
  CustomCodeAnalysisPlugin(ResourceProvider provider) : super(provider);

  var _filesFromSetPriorityFilesRequest = <String>[];

  late YamlMap _yamlMap;

  String? _sourceUri;

  @override
  List<String> get fileGlobsToAnalyze => <String>['**/*.dart'];

  @override
  String get name => 'Custom Code Analysis';

  @override
  String get version => '1.0.0';

  // @override
  // Future<plugin.PluginVersionCheckResult> handlePluginVersionCheck(plugin.PluginVersionCheckParams parameters) {
  //   logUtil.info('parameters = $parameters');
  //   channel.sendNotification(plugin.PluginErrorParams(false, 'customErroor', parameters.toString()).toNotification());
  //   return super.handlePluginVersionCheck(parameters);
  // }

  @override
  void contentChanged(String path) {
    AnalysisDriverGeneric driver = super.driverForPath(path)!;
    logUtil.info('File content changed: $path');
    driver.addFile(path);
  }

  // @override
  // AnalysisDriverGeneric createAnalysisDriver(plugin.ContextRoot contextRoot) {
  //   logUtil.info('context root: ${contextRoot.root}');
  //   final analysisOptionsFile = io.File(p.absolute(contextRoot.root, analysisOptionsFileName));
  //   _yamlMap = (loadYaml(analysisOptionsFile.readAsStringSync()) as YamlMap?)!;
  //   // logUtil.info('_yamlMap = $_yamlMap');
  //   final analysisRoot = analyzer.ContextRoot(contextRoot.root, contextRoot.exclude, pathContext: resourceProvider.pathContext)
  //     ..optionsFilePath = contextRoot.optionsFile;
  //
  //   final contextBuilder = ContextBuilder(resourceProvider, sdkManager, null)
  //     ..analysisDriverScheduler = analysisDriverScheduler
  //     ..byteStore = byteStore
  //     ..performanceLog = performanceLog;
  //
  //   final workspace = ContextBuilder.createWorkspace(
  //     resourceProvider: resourceProvider,
  //     options: ContextBuilderOptions(),
  //     rootPath: contextRoot.root,
  //   );
  //
  //   final dartDriver = contextBuilder.buildDriver(analysisRoot, workspace);
  //   _sourceUri = _getSourceUri(dartDriver);
  //   runZonedGuarded(
  //     () {
  //       dartDriver.results.listen((analysisResult) {
  //         logUtil.info('received analysis result from file: ${analysisResult.libraryElement.source.fullName}');
  //         _processResult(dartDriver, analysisResult);
  //       });
  //     },
  //     _onError,
  //   );
  //
  //   return dartDriver;
  // }

  final _byteStore = createByteStore(PhysicalResourceProvider.INSTANCE);

  @override
  AnalysisDriverGeneric createAnalysisDriver(plugin.ContextRoot contextRoot) {
    final analysisOptionsFile = io.File(p.absolute(contextRoot.root, analysisOptionsFileName));
    _yamlMap = (loadYaml(analysisOptionsFile.readAsStringSync()) as YamlMap?)!;

    final rootPath = contextRoot.root;
    final locator = ContextLocator(resourceProvider: resourceProvider).locateRoots(
      includedPaths: [rootPath],
      excludedPaths: contextRoot.exclude,
      optionsFile: contextRoot.optionsFile,
    );

    if (locator.isEmpty) {
      final error = StateError('Unexpected empty context');
      channel.sendNotification(plugin.PluginErrorParams(
        true,
        error.message,
        error.stackTrace.toString(),
      ).toNotification());

      throw error;
    }

    final builder = ContextBuilderImpl(resourceProvider: resourceProvider);
    final context = builder.createContext(
      contextRoot: locator.first,
      byteStore: _byteStore,
    );
    final dartDriver = context.driver;
    // final config = _crexateConfig(dartDriver, rootPath);

    // if (config == null) {
    //   return dartDriver;
    // }

    _sourceUri = _getSourceUri(dartDriver);
    // Temporary disable deprecation check
    //
    // final deprecations = checkConfigDeprecatedOptions(
    //   config,
    //   deprecatedOptions,
    //   contextRoot.optionsFile!,
    // );
    // if (deprecations.isNotEmpty) {
    //   channel.sendNotification(plugin.AnalysisErrorsParams(
    //     contextRoot.optionsFile!,
    //     deprecations.map((deprecation) => deprecation.error).toList(),
    //   ).toNotification());
    // }

    runZonedGuarded(
      () {
        dartDriver.results.listen((analysisResult) {
          if (analysisResult is ResolvedUnitResult) {
            _processResult(dartDriver, analysisResult);
          }
        });
      },
      (e, stackTrace) {
        channel.sendNotification(
          plugin.PluginErrorParams(false, e.toString(), stackTrace.toString()).toNotification(),
        );
      },
    );

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
    final filesByDriver = <AnalysisDriverGeneric?, List<String>>{};
    for (final file in filesToFullyResolve) {
      final contextRoot = contextRootContaining(file);
      if (contextRoot != null) {
        final driver = driverMap[contextRoot];
        filesByDriver.putIfAbsent(driver, () => <String>[]).add(file);
      }
    }
    filesByDriver.forEach((driver, files) => driver!.priorityFiles = files);
  }

  String? _getSourceUri(AnalysisDriver dartDriver) {
    String? _uri;
    // ignore: deprecated_member_use
    String? _optionsFile = dartDriver.analysisContext!.contextRoot.optionsFile!.path;
    _uri = dartDriver.resourceProvider.pathContext.dirname(_optionsFile);
    return _uri;
  }

  void _processResult(AnalysisDriver driver, ResolvedUnitResult analysisResult) {
    try {
      String _fullName = analysisResult.unit.declaredElement!.source.fullName;

      var globList = AnalysisOptions.fromYamlMap(_yamlMap).excludes!.map((e) => Glob(p.join(_sourceUri!, e))).toList();
      if (globList.any((glob) => glob.matches(_fullName))) {
        return;
      }

      List<Issue> issueList = [];
      for (final ruleId in AnalysisOptions.fromYamlMap(_yamlMap).rules!) {
        // logUtil.info('ruleId = $ruleId');
        var rule = findRuleById(ruleId);
        if (rule != null) {
          issueList.addAll(rule.check(analysisResult));
          // print('issueList =$issueList');
        }
      }
      if (issueList.isNotEmpty) {
        // logUtil.info('send Notification: ${issueList.length}');
        channel.sendNotification(
          plugin.AnalysisErrorsParams(
            analysisResult.path,
            issueList.map((issue) => codeIssueToAnalysisError(issue, analysisResult)).toList(),
          ).toNotification(),
        );
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
      final analysisResult = await driver.getResult(parameters.file) as ResolvedUnitResult;

      List<AnalysisErrorFixes> errorFixes = [];
      for (final ruleId in AnalysisOptions.fromYamlMap(_yamlMap).rules!) {
        var rule = findRuleById(ruleId);
        if (rule != null) {
          errorFixes.addAll(codeIssueToAnalysisErrorFixes(rule.check(analysisResult) as List<Issue>, analysisResult));
        }
      }

      return plugin.EditGetFixesResult(errorFixes);
    } on Exception catch (e, stackTrace) {
      channel.sendNotification(plugin.PluginErrorParams(false, e.toString(), stackTrace.toString()).toNotification());

      return plugin.EditGetFixesResult([]);
    }
  }
}
