import 'package:analyzer/dart/analysis/results.dart';
import 'package:custom_code_analysis/src/model/rule.dart';

class AvoidUsingShowDatePicker extends Rule {
  AvoidUsingShowDatePicker(
    String ruleId,
    ResolvedUnitResult analysisResult,
  ) : super(ruleId: ruleId, analysisResult: analysisResult);

  @override
  String get code => ruleId;

  @override
  String get comment => '快速添加';

  @override
  String get correction => '原生$methodName函数禁止调用';

  @override
  String get message => '禁止使用原生$methodName类';

  @override
  String get methodName => 'showDatePicker';
}
