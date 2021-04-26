import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_code_analysis/src/rules/avoid_using_colors.dart';
import 'package:custom_code_analysis/src/rules/avoid_using_show_bottom_modal_sheet.dart';
import 'package:custom_code_analysis/src/rules/avoid_using_show_bottom_sheet.dart';
import 'package:custom_code_analysis/src/rules/avoid_using_show_date_picker.dart';
import 'package:custom_code_analysis/src/rules/avoid_using_show_date_range_picker.dart';
import 'package:custom_code_analysis/src/rules/avoid_using_show_dialog.dart';
import 'package:custom_code_analysis/src/rules/avoid_using_show_general_dialog.dart';
import 'package:custom_code_analysis/src/rules/avoid_using_show_menu.dart';
import 'package:custom_code_analysis/src/rules/avoid_using_show_search.dart';
import 'package:custom_code_analysis/src/rules/avoid_using_show_time_picker.dart';
import 'package:custom_code_analysis/src/rules/clickable_widget_id_missing.dart';
import 'package:custom_code_analysis/src/rules/override_hashcode_method.dart';

typedef RuleType = Function(CompilationUnit compilationUnit, ResolvedUnitResult analysisResult);

Map<String, RuleType> ruleConfigs = {
  AvoidUsingColors.ruleId: (CompilationUnit compilationUnit, ResolvedUnitResult analysisResult) => AvoidUsingColors(compilationUnit, analysisResult),
  AvoidUsingShowBottomModalSheet.ruleId: (CompilationUnit compilationUnit, ResolvedUnitResult analysisResult) =>
      AvoidUsingShowBottomModalSheet(compilationUnit, analysisResult),
  AvoidUsingShowBottomSheet.ruleId: (CompilationUnit compilationUnit, ResolvedUnitResult analysisResult) =>
      AvoidUsingShowBottomSheet(compilationUnit, analysisResult),
  AvoidUsingShowDatePicker.ruleId: (CompilationUnit compilationUnit, ResolvedUnitResult analysisResult) =>
      AvoidUsingShowDatePicker(compilationUnit, analysisResult),
  AvoidUsingShowDateRangePicker.ruleId: (CompilationUnit compilationUnit, ResolvedUnitResult analysisResult) =>
      AvoidUsingShowDateRangePicker(compilationUnit, analysisResult),
  AvoidUsingShowDialog.ruleId: (CompilationUnit compilationUnit, ResolvedUnitResult analysisResult) => AvoidUsingShowDialog(compilationUnit, analysisResult),
  AvoidUsingShowGeneralDialog.ruleId: (CompilationUnit compilationUnit, ResolvedUnitResult analysisResult) =>
      AvoidUsingShowGeneralDialog(compilationUnit, analysisResult),
  AvoidUsingShowMenu.ruleId: (CompilationUnit compilationUnit, ResolvedUnitResult analysisResult) => AvoidUsingShowMenu(compilationUnit, analysisResult),
  AvoidUsingShowSearch.ruleId: (CompilationUnit compilationUnit, ResolvedUnitResult analysisResult) => AvoidUsingShowSearch(compilationUnit, analysisResult),
  AvoidUsingShowTimePicker.ruleId: (CompilationUnit compilationUnit, ResolvedUnitResult analysisResult) =>
      AvoidUsingShowTimePicker(compilationUnit, analysisResult),
  ClickableWidgetIdMissing.ruleId: (CompilationUnit compilationUnit, ResolvedUnitResult analysisResult) =>
      ClickableWidgetIdMissing(compilationUnit, analysisResult),
  OverrideHashcodeMethod.ruleId: (CompilationUnit compilationUnit, ResolvedUnitResult analysisResult) =>
      OverrideHashcodeMethod(compilationUnit, analysisResult),
};
