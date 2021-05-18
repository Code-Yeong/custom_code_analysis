import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/model/rule.dart';
import 'package:analyzer/src/ignore_comments/ignore_info.dart';

class OverrideHashcodeMethod extends Rule {
  OverrideHashcodeMethod(
    String ruleId,
    ResolvedUnitResult analysisResult,
  ) : super(ruleId: ruleId, analysisResult: analysisResult);

  @override
  String get code => ruleId;

  @override
  String get comment => '快速修复';

  @override
  String get correction => '$methodName中要包含每个field';

  @override
  String get message => '$methodName不全';

  @override
  String get methodName => 'hashCode';

  @override
  Iterable<Issue> check() {
    final visitor = _MirrorVisitor(analysisResult, this);
    analysisResult.unit.accept(visitor);

    return visitor.nodes
        .map((node) => Issue(
              errorSeverity: AnalysisErrorSeverity.INFO,
              errorType: AnalysisErrorType.HINT,
              offset: node.offset,
              length: node.length,
              line: analysisResult.unit.lineInfo.getLocation(node.offset).lineNumber,
              column: analysisResult.unit.lineInfo.getLocation(node.offset).columnNumber,
              message: message,
              code: code,
              correction: correction,
              replacement: generateReplacement(node),
              hasFix: false,
            ))
        .toList();
  }

  String generateReplacement(ExpressionFunctionBody node) {
    String fixStr = '';
    var className = node.parent.parent.beginToken.next.lexeme;
    var targetElement = analysisResult.unit.declaredElement.library.getType(className);
    if (targetElement.supertype.getDisplayString(withNullability: false) == 'ReduxViewModel') {
      var fields = targetElement.unnamedConstructor.parameters;
      for (final field in fields) {
        String displayName = '${field.displayName}.hashCode';
        fixStr = '$fixStr ^ $displayName';
      }
    }

    fixStr = fixStr.replaceRange(0, 3, '');
    // print('fixStr = $fixStr');
    return fixStr;
  }
}

class _MirrorVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];
  final ResolvedUnitResult analysisResult;
  final Rule rule;

  _MirrorVisitor(this.analysisResult, this.rule);

  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    if (node.parent.beginToken.lexeme == '@') {
      if (node.parent.beginToken.next.lexeme == 'override') {
        if (node.parent.beginToken.next.next.lexeme == 'int') {
          if (node.parent.beginToken.next.next.next.lexeme == 'get') {
            if (node.parent.beginToken.next.next.next.next.lexeme == 'hashCode') {
              bool _needFix = false;
              var className = node.parent.parent.beginToken.next.lexeme;
              var targetElement = analysisResult.unit.declaredElement.library.getType(className);
              if (targetElement.supertype.getDisplayString(withNullability: false) == 'ReduxViewModel') {
                var fields = targetElement.unnamedConstructor.parameters;
                String hashString = node.expression.toString();
                // print('hashString = $hashString');
                for (final field in fields) {
                  String displayName = '${field.displayName}.hashCode';
                  // print('testName: $displayName');
                  if (!hashString.contains(displayName)) {
                    _needFix = true;
                    break;
                  }
                }
              }
              if (_needFix) {
                int lineNumber = analysisResult.unit.lineInfo.getLocation(node.offset).lineNumber;
                var ignoreInfo = IgnoreInfo.forDart(analysisResult.unit, analysisResult.content);
                if (!ignoreInfo.ignoredAt(rule.code, lineNumber)) {
                  _nodes.add(node);
                }
              }
            }
          }
        }
      }
    }
  }
}
