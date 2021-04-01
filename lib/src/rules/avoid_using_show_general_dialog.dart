import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/model/rule.dart';

class AvoidUsingShowGeneralDialog extends Rule {
  AvoidUsingShowGeneralDialog(
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
  String get methodName => 'showGeneralDialog';
}
