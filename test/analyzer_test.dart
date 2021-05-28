import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:custom_code_analysis/src/configs/rule_config.dart';
import 'package:custom_code_analysis/src/model/rule.dart';
import 'package:test/test.dart';
import 'package:path/path.dart';

void main() {
  test('Check:clickable-widget-uuid-missing', () async {
    final filePath = '${Directory.current.path}/assets_test/clickable_widget_uuid_missing.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('clickable-widget-uuid-missing');
    var resultList = _codeRule.check(unit);
    // print(resultList);
    expect(resultList.length, 8);
  });

  test('Check:avoid-using-color', () async {
    final filePath = '${Directory.current.path}/assets_test/avoid_using_color.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-color');
    var resultList = _codeRule.check(unit);
    // print(resultList);
    expect(resultList.length, 2);
  });

  test('Check:avoid-using-colors', () async {
    final filePath = '${Directory.current.path}/assets_test/avoid_using_colors.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-colors');
    var resultList = _codeRule.check(unit);
    // print(resultList);
    expect(resultList.length, 3);
  });

  test('Check:avoid-using-show-bottom-modal-sheet', () async {
    final filePath = '${Directory.current.path}/assets_test/avoid_using_show_bottom_modal_sheet.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-bottom-modal-sheet');
    var resultList = _codeRule.check(unit);
    // print(resultList);
    expect(resultList.length, 1);
  });

  test('Check:avoid-using-show-bottom-sheet', () async {
    final filePath = '${Directory.current.path}/assets_test/avoid_using_show_bottom_sheet.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-bottom-sheet');
    var resultList = _codeRule.check(unit);
    // print(resultList);
    expect(resultList.length, 1);
  });

  test('Check:avoid-using-show-date-picker', () async {
    final filePath = '${Directory.current.path}/assets_test/avoid_using_show_date_picker.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-date-picker');
    var resultList = _codeRule.check(unit);
    // print(resultList);
    expect(resultList.length, 1);
  });

  test('Check:avoid-using-show-date-range-picker', () async {
    final filePath = '${Directory.current.path}/assets_test/avoid_using_show_date_range_picker.dart';
    final analysisContextCollection = AnalysisContextCollection(
      includedPaths: [filePath],
      excludedPaths: [],
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final normalizedPath = normalize(filePath);
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-date-range-picker');
    var resultList = _codeRule.check(unit);
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
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-dialog');
    var resultList = _codeRule.check(unit);
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
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-general-dialog');
    var resultList = _codeRule.check(unit);
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
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-menu');
    var resultList = _codeRule.check(unit);
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
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-search');
    var resultList = _codeRule.check(unit);
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
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('avoid-using-show-time-picker');
    var resultList = _codeRule.check(unit);
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
    ResolvedUnitResult unit = await analysisContextCollection.contextFor(normalizedPath).currentSession.getResolvedUnit(normalizedPath);
    Rule _codeRule = findRuleById('override-hash-code-method');
    var resultList = _codeRule.check(unit);
    // print(resultList);
    expect(resultList.length, 2);
  });
}
