import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:custom_code_analysis/src/utils/suppression.dart';

// import 'package:analyzer/src/ignore_comments/ignore_info.dart';
// import 'package:custom_code_analysis/src/logger/log.dart';
import '../model/rule.dart';

class CodeIssueVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];
  final ResolvedUnitResult? analysisResult;
  final Rule? rule;

  CodeIssueVisitor({this.analysisResult, this.rule});

  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    node.visitChildren(this);
    // logUtil.info('name = ${node.methodName.name}, method = ${rule!.methodName}');
    if (node.methodName.name == rule!.methodName) {
      int lineNumber = analysisResult!.unit.lineInfo!.getLocation(node.offset).lineNumber;
      final ignores = Suppression(analysisResult!.content, analysisResult!.lineInfo);
      if (!ignores.isSuppressedAt(rule!.code!.replaceAll('-', '_'), lineNumber)) {
        _nodes.add(node);
      }
    }
  }
}
