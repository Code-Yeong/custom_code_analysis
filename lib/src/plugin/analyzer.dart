// ignore_for_file: comment_references
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:custom_code_analysis/src/cli/config.dart';
import 'package:custom_code_analysis/src/cli/store.dart';
import 'package:custom_code_analysis/src/configs/rule_config.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/model/rule.dart';
import 'package:file/local.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

/// Performs code quality analysis on specified files
/// See [MetricsAnalysisRunner] to get analysis info
// @Deprecated('will be replaced with LintAnalyzer in 4.0')
class CustomAnalyzer {
  final Iterable<Glob> _globalExclude;
  final Iterable<Rule> _codeRules;

  final CustomAnalyzerStore _store;

  CustomAnalyzer(Config config, CustomAnalyzerStore store)
      : _globalExclude = _prepareExcludes(config.excludePatterns),
        _codeRules = getRulesById(config.rules),
        _store = store;

  /// Return a future that will complete after static analysis done for files from [folders].
  Future<void> runAnalysis(Iterable<String> folders, String rootFolder) async {
    final collection = AnalysisContextCollection(
      includedPaths: folders.map((path) => p.normalize(p.join(rootFolder, path))).toList(),
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );

    final filePaths = folders
        .expand((directory) => Glob('$directory/**.dart')
            .listFileSystemSync(
              const LocalFileSystem(),
              root: rootFolder,
              followLinks: false,
            )
            .whereType<File>()
            .where((entity) => !_isExcluded(
                  p.relative(entity.path, from: rootFolder),
                  _globalExclude,
                ))
            .map((entity) => entity.path))
        .toList();

    for (final filePath in filePaths) {
      final normalized = p.normalize(p.absolute(filePath));

      final analysisContext = collection.contextFor(normalized);
      final result =
          // ignore: deprecated_member_use
          await analysisContext.currentSession.getResolvedUnit(normalized);

      final unit = result.unit;
      final content = result.content;
      if (unit == null || content == null || result.state != ResultState.VALID) {
        continue;
      }

      /// 记录结果
      var resultList = _checkOnCodeIssues(filePath, rootFolder, result);
      _store.storeAll(resultList);
    }
  }

  Iterable<Issue> _checkOnCodeIssues(
    String filePath,
    String rootFolder,
    ResolvedUnitResult analysisResult,
  ) =>
      _codeRules.expand(
        (rule) => rule.check(analysisResult),
      ).toList();
}

Iterable<Glob> _prepareExcludes(Iterable<String> patterns) => patterns.map((exclude) => Glob(exclude)).toList() ?? [];

bool _isExcluded(String filePath, Iterable<Glob> excludes) => excludes.any((exclude) => exclude.matches(filePath));
