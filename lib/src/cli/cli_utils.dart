import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/precedence.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:custom_code_analysis/src/logger/log.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/rules/avoid_using_show_dialog.dart';
import 'package:custom_code_analysis/src/rules/clickable_widget_id_missing.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

List<String> excludedFilesFromAnalysisOptions(File analysisOptions) {
  final parsedOptions = loadYaml(analysisOptions.readAsStringSync()) as YamlMap;
  final analyzerSection = parsedOptions.nodes['analyzer'];
  if (analysisOptions != null) {
    final dynamic excludedSection = (analyzerSection as YamlMap)['exclude'];
    if (excludedSection != null) {
      // ignore: avoid_annotating_with_dynamic
      return (excludedSection as YamlList).map((dynamic path) => path as String).toList();
    }
  }
  return [];
}

List<String> resolvePaths(List<String> paths, List<String> excludedFolders) {
  final excludedGlobs = excludedFolders.map((path) => Glob(path)).toList();
  return paths
      .expand((path) => Glob('$path/**/*.dart').listSync().whereType<File>().where((file) => !_isExcluded(file.path, excludedGlobs)).map((e) => e.path))
      .toList();
}

bool _isExcluded(String filePath, Iterable<Glob> excludes) => excludes.any((exclude) => exclude.matches(filePath));

Future<List<AnalysisError>> collectAnalyzerErrors(AnalysisContextCollection analysisContextCollection, List<String> paths) async {
  final analysisErrors = <AnalysisError>[];
  for (final filePath in paths) {
    final normalizedPath = normalize(filePath);
    // var stopWatch = Stopwatch();
    // stopWatch.start();
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    // ParsedUnitResult parsedUnit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getParsedUnit(normalizedPath);
    // stopWatch.stop();
    // print('timeCost = ${stopWatch.elapsedMilliseconds}'); //timeCost = 2345 , 80
    // parsedUnit.unit

    // logUtil.info('${unit.content}');
    // logUtil.info('unit.libraryElement.units = ${unit.libraryElement.importedLibraries.first.units}');
    // logUtil.info('unit.libraryElement.units = ${unit.libraryElement.importedLibraries.first.units.first.getType('Clickable')}');
    // var result = unit.libraryElement.importedLibraries.first.units.first.getType('Clickable');
    // var result2 = unit.libraryElement.importedLibraries.first.units.first.getType('RoundButton');
    // logUtil.info('result = ${result.fields}');
    // logUtil.info('result2 = ${result2}');

    // final issuesInFile = ClickableWidgetIdMissing(null, unit);

    // test ignored
    // final rule = AvoidUsingShowDialog('avoid-using-show-dialog', unit);
    final rule = ClickableWidgetIdMissing('clickable-widget-uuid-missing', unit);
    analysisErrors.addAll(rule.check().map((e) => codeIssueToAnalysisError(e, unit)).toList());
  }
  return analysisErrors;
}

String readableAnalysisError(AnalysisError analysisError) => analysisError.toReadableString();

AnalysisError codeIssueToAnalysisError(Issue issue, ResolvedUnitResult analysisResult) {
  return AnalysisError(
    issue.errorSeverity,
    issue.errorType,
    Location(
      analysisResult.unit.declaredElement.source.fullName,
      issue.offset,
      issue.length,
      issue.line,
      issue.column,
    ),
    issue.message,
    issue.code,
    correction: issue.correction,
    hasFix: issue.hasFix,
  );
}

extension ReadableOutput on AnalysisError {
  String toReadableString() => '$severity - $type\n$message\n${location.file}:${location.startLine}:${location.startColumn}';
}
