import 'dart:io';

import 'package:custom_code_analysis/src/cli/arguments_parser.dart';
import 'package:custom_code_analysis/src/cli/arguments_validation.dart';
import 'package:custom_code_analysis/src/cli/config.dart';
import 'package:custom_code_analysis/src/cli/store.dart';
import 'package:custom_code_analysis/src/model/analysis_options.dart';
import 'package:custom_code_analysis/src/plugin/analyzer.dart';
import 'package:custom_code_analysis/src/reporter/console_reporter.dart';
import 'package:custom_code_analysis/src/reporter/json_reporter.dart';
import 'package:custom_code_analysis/src/reporter/reporter.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const String analysisOptionsFileName = 'analysis_options.yaml';

final _parser = argumentsParser();

Future<void> main(List<String> args) async {
  try {
    final arguments = _parser.parse(args);

    if (arguments[helpFlagName] as bool) {
      _showUsageAndExit(0);
    }

    validateArguments(arguments);
    await _runAnalysis(
      arguments[rootFolderName] as String,
      arguments.rest,
      arguments[reporterName] as String,
      arguments[verboseName] as bool,
      arguments[gitlabCompatibilityName] as bool,
    );
  } on Exception catch (e) {
    print('$e\n');
    _showUsageAndExit(1);
  }
}

void _showUsageAndExit(int exitCode) {
  print(usageHeader);
  print(_parser.usage);
  exit(exitCode);
}

Future<void> _runAnalysis(
  String rootFolder,
  Iterable<String> analysisDirectories,
  String reporterType,
  bool verbose,
  bool gitlab,
) async {
  final analysisOptionsFile = File(p.absolute(rootFolder, analysisOptionsFileName));
  var _yamlMap = loadYaml(analysisOptionsFile.readAsStringSync()) as YamlMap;

  final options = analysisOptionsFile.existsSync()
      ? await AnalysisOptions.fromYamlMap(_yamlMap)
      : AnalysisOptions(
          excludes: [],
          rules: [],
        );

  final store = CustomAnalyzerStore();
  Config config = Config.fromAnalysisOptions(options);
  final analyzer = CustomAnalyzer(config, store);
  await analyzer.runAnalysis(analysisDirectories, rootFolder);
  // print('reporterType = $reporterType');
  Reporter reporter;

  switch (reporterType) {
    case 'console':
      reporter = ConsoleReporter();
      break;
    case 'github':
      // reporter = GitHubReporter();
      break;
    case 'json':
      reporter = JsonReporter();
      break;
    case 'html':
      // reporter = HtmlReporter(reportConfig: config);
      break;
    case 'codeclimate':
      // reporter = CodeClimateReporter(reportConfig: config, gitlabCompatible: gitlab);
      break;
    default:
      throw ArgumentError.value(reporterType, 'reporter');
  }

  (await reporter.report(store.issueList)).forEach(print);
}
