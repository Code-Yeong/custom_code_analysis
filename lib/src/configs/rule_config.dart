import 'package:custom_code_analysis/src/rules/avoid_using_colors.dart';
import 'package:analyzer/dart/analysis/results.dart';
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
import '../model/rule.dart';

Rule findRule(String ruleId, ResolvedUnitResult analysisResult) {
  return {
    'avoid-using-colors': AvoidUsingColors('avoid-using-colors', analysisResult),
    'avoid-using-show-bottom-modal-sheet': AvoidUsingShowBottomModalSheet('avoid-using-show-bottom-modal-sheet', analysisResult),
    'avoid-using-show-bottom-sheet': AvoidUsingShowBottomSheet('avoid-using-show-bottom-sheet', analysisResult),
    'avoid-using-show-date-picker': AvoidUsingShowDatePicker('avoid-using-show-date-picker', analysisResult),
    'avoid-using-show-date-range-picker': AvoidUsingShowDateRangePicker('avoid-using-show-date-range-picker', analysisResult),
    'avoid-using-show-dialog': AvoidUsingShowDialog('avoid-using-show-dialog', analysisResult),
    'avoid-using-show-general-dialog': AvoidUsingShowGeneralDialog('avoid-using-show-general-dialog', analysisResult),
    'avoid-using-show-menu': AvoidUsingShowMenu('avoid-using-show-menu', analysisResult),
    'avoid-using-show-search': AvoidUsingShowSearch('avoid-using-show-search', analysisResult),
    'avoid-using-show-time-picker': AvoidUsingShowTimePicker('avoid-using-show-time-picker', analysisResult),
    'clickable-widget-uuid-missing': ClickableWidgetIdMissing('clickable-widget-uuid-missing', analysisResult),
    'override-hashCode-method': OverrideHashcodeMethod('override-hashCode-method', analysisResult),
  }[ruleId];
}
