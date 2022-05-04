import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:custom_code_analysis/src/configs/rule_config.dart';
import 'package:custom_code_analysis/src/model/rule.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('Check:clickable-widget-uuid-missing', () async {
    final filePath = '${Directory.current.path}/assets_test/clickable_widget_uuid_missing.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );

    final normalizedPath = normalize(filePath);

    for (final context in analysisContextCollection.contexts) {
      context.currentSession.getErrors(normalizedPath);
      print(context.contextRoot.analyzedFiles().toList());
    }

    final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    // final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('clickable-widget-uuid-missing')!;
    var resultList = _codeRule.check(unit as ResolvedUnitResult);
    // print(resultList);
    expect(resultList.length, 8);
  });

  test('Check:avoid-using-show-date-range-picker', () async {
    final filePath = '${Directory.current.path}/assets_test/avoid_using_show_date_range_picker.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-date-range-picker')!;
    var resultList = _codeRule.check(unit as ResolvedUnitResult);
    // print(resultList);
    expect(resultList.length, 1);
  });

  test('Check:avoid-using-show-dialog', () async {
    final filePath = '${Directory.current.path}/assets_test/avoid_using_show_dialog.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-dialog')!;
    var resultList = _codeRule.check(unit as ResolvedUnitResult);
    // print(resultList);
    expect(resultList.length, 1);
  });

  test('Check:avoid-using-show-general-dialog', () async {
    final filePath = '${Directory.current.path}/assets_test/avoid_using_show_general_dialog.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-general-dialog')!;
    var resultList = _codeRule.check(unit as ResolvedUnitResult);
    // print(resultList);
    expect(resultList.length, 1);
  });

  test('Check:avoid-using-show-menu', () async {
    final filePath = '${Directory.current.path}/assets_test/avoid_using_show_menu.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-menu')!;
    var resultList = _codeRule.check(unit as ResolvedUnitResult);
    // print(resultList);
    expect(resultList.length, 1);
  });

  test('Check:avoid-using-show-search', () async {
    final filePath = '${Directory.current.path}/assets_test/avoid_using_show_search.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-search')!;
    var resultList = _codeRule.check(unit as ResolvedUnitResult);
    // print(resultList);
    expect(resultList.length, 1);
  });

  test('Check:avoid-using-show-time-picker', () async {
    final filePath = '${Directory.current.path}/assets_test/avoid_using_show_time_picker.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-time-picker')!;
    var resultList = _codeRule.check(unit as ResolvedUnitResult);
    // print(resultList);
    expect(resultList.length, 1);
  });

  test('Check:override-hash-code-method', () async {
    final filePath = '${Directory.current.path}/assets_test/override_hash_code_method.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    final unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('override-hash-code-method')!;
    var resultList = _codeRule.check(unit as ResolvedUnitResult);
    // print(resultList);
    expect(resultList.length, 2);
  });
}
