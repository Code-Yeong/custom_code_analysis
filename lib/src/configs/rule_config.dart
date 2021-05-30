import 'package:custom_code_analysis/src/rules/avoid_using_color.dart';
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
import 'package:custom_code_analysis/src/rules/override_hash_code_method.dart';

import '../model/rule.dart';

Map<String, Rule> registeredRulesMap = {
  'avoid-using-color': AvoidUsingColor('avoid-using-color'),
  'avoid-using-colors': AvoidUsingColors('avoid-using-colors'),
  'avoid-using-show-bottom-modal-sheet': AvoidUsingShowBottomModalSheet('avoid-using-show-bottom-modal-sheet'),
  'avoid-using-show-bottom-sheet': AvoidUsingShowBottomSheet('avoid-using-show-bottom-sheet'),
  'avoid-using-show-date-picker': AvoidUsingShowDatePicker('avoid-using-show-date-picker'),
  'avoid-using-show-date-range-picker': AvoidUsingShowDateRangePicker('avoid-using-show-date-range-picker'),
  'avoid-using-show-dialog': AvoidUsingShowDialog('avoid-using-show-dialog'),
  'avoid-using-show-general-dialog': AvoidUsingShowGeneralDialog('avoid-using-show-general-dialog'),
  'avoid-using-show-menu': AvoidUsingShowMenu('avoid-using-show-menu'),
  'avoid-using-show-search': AvoidUsingShowSearch('avoid-using-show-search'),
  'avoid-using-show-time-picker': AvoidUsingShowTimePicker('avoid-using-show-time-picker'),
  'clickable-widget-uuid-missing': ClickableWidgetIdMissing('clickable-widget-uuid-missing'),
  'override-hash-code-method': OverrideHashcodeMethod('override-hash-code-method'),
};

Rule? findRuleById(String ruleId) {
  return registeredRulesMap[ruleId];
}

List<Rule?> getRulesById(List<String> rulesId) {
  return rulesId.map((id) => registeredRulesMap[id]).toList();
}
