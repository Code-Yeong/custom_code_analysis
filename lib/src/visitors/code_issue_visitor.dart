import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/src/ignore_comments/ignore_info.dart';
import '../model/rule.dart';

class CodeIssueVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];
  final ResolvedUnitResult analysisResult;
  final Rule rule;

  CodeIssueVisitor({this.analysisResult, this.rule});

  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    node.visitChildren(this);
    if (node.methodName.name.contains(rule.methodName)) {
      int lineNumber = analysisResult.unit.lineInfo.getLocation(node.offset).lineNumber;
      var ignoreInfo = IgnoreInfo.forDart(analysisResult.unit, analysisResult.content);
      if (!ignoreInfo.ignoredAt(rule.code, lineNumber)) {
        _nodes.add(node);
      }
    }
  }
}