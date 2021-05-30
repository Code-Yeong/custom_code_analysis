import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/src/ignore_comments/ignore_info.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/model/rule.dart';

class AvoidUsingColor extends Rule {
  AvoidUsingColor(String ruleId) : super(ruleId: ruleId);

  @override
  String? get code => ruleId;

  @override
  String get comment => '快速添加';

  @override
  String get correction => '原生$methodName函数禁止调用';

  @override
  String get message => '禁止使用原生$methodName类';

  @override
  String get methodName => 'Color';

  @override
  Iterable<Issue> check(ResolvedUnitResult analysisResult) {
    final visitor = ColorCodeIssueVisitor(analysisResult: analysisResult, rule: this);
    analysisResult.unit!.accept(visitor);
    return visitor.nodes
        .map((node) => Issue(
              errorSeverity: AnalysisErrorSeverity.INFO,
              errorType: AnalysisErrorType.HINT,
              offset: node.offset,
              length: node.length,
              line: analysisResult.unit!.lineInfo!.getLocation(node.offset).lineNumber,
              column: analysisResult.unit!.lineInfo!.getLocation(node.offset).columnNumber,
              endLine: analysisResult.unit!.lineInfo!.getLocation(node.end).lineNumber,
              endColumn: analysisResult.unit!.lineInfo!.getLocation(node.end).columnNumber,
              message: message,
              code: code,
              correction: correction,
              hasFix: false,
              filePath: analysisResult.unit!.declaredElement!.source.fullName,
            ))
        .toList();
  }
}

class ColorCodeIssueVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];
  final ResolvedUnitResult? analysisResult;
  final Rule? rule;

  ColorCodeIssueVisitor({this.analysisResult, this.rule});

  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name == rule!.methodName) {
      int lineNumber = analysisResult!.unit!.lineInfo!.getLocation(node.offset).lineNumber;
      var ignoreInfo = IgnoreInfo.forDart(analysisResult!.unit!, analysisResult!.content!);
      if (!ignoreInfo.ignoredAt(rule!.code!.replaceAll('-', '_'), lineNumber)) {
        _nodes.add(node);
      }
    }
    super.visitSimpleIdentifier(node);
  }
}
