import 'package:custom_code_analysis/src/model/rule.dart';

class AvoidUsingShowDialog extends Rule {
  AvoidUsingShowDialog(String ruleId) : super(ruleId: ruleId);

  @override
  String? get code => ruleId;

  @override
  String get comment => '快速添加';

  @override
  String get correction => '原生$methodName函数禁止调用';

  @override
  String get message => '禁止使用原生$methodName类';

  @override
  String get methodName => 'showDialog';
}
