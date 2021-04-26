import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/model/rule.dart';
import 'package:custom_code_analysis/src/utils/ingores.dart';

class OverrideHashcodeMethod extends Rule {
  final CompilationUnit _compilationUnit;
  final ResolvedUnitResult analysisResult;
  String unitPath;
  Suppressions _ignores;
  static const ruleId = 'override-hashCode-method';
  static const code = ruleId;
  static const methodName = 'hashCode';
  static const comment = '快速修复';
  static const message = '$methodName不全';
  static const correction = '$methodName中要包含每个field';

  OverrideHashcodeMethod(this._compilationUnit, this.analysisResult) {
    unitPath = this._compilationUnit.declaredElement.source.fullName;
    _ignores = Suppressions(analysisResult.content, _compilationUnit.lineInfo);
  }

  @override
  Iterable<ErrorIssue> errors() {
    final visitor = _MirrorVisitor(_compilationUnit, _ignores);
    _compilationUnit.accept(visitor);
    return visitor.nodes.map(
      (node) {
        return ErrorIssue(
          error: plugin.AnalysisError(
            plugin.AnalysisErrorSeverity.INFO,
            plugin.AnalysisErrorType.HINT,
            plugin.Location(
              _compilationUnit.declaredElement.source.fullName,
              node.offset,
              node.length,
              _compilationUnit.lineInfo.getLocation(node.offset).lineNumber,
              _compilationUnit.lineInfo.getLocation(node.offset).columnNumber,
            ),
            message,
            code,
            correction: correction,
            hasFix: true,
          ),
          replacement: generateReplacement(node),
        );
      },
    ).toList();
  }

  plugin.AnalysisErrorFixes codeIssueToAnalysisErrorFixes2(ErrorIssue error, ResolvedUnitResult unitResult) {
    return plugin.AnalysisErrorFixes(
      error.error,
      fixes: [
        if (error.error.correction != null)
          plugin.PrioritizedSourceChange(
            99,
            plugin.SourceChange(
              comment,
              edits: [
                plugin.SourceFileEdit(
                  unitResult.libraryElement.source.fullName,
                  unitResult.libraryElement.source.modificationStamp,
                  edits: [
                    plugin.SourceEdit(
                      error.error.location.offset,
                      error.error.location.length,
                      error.replacement,
                    ),
                  ],
                ),
              ],
              // selection: Position(unitResult.libraryElement.source.fullName, issue.offset),
            ),
          ),
      ],
    );
  }

  String generateReplacement(ExpressionFunctionBody node) {
    String fixStr = '';
    var className = node.parent.parent.beginToken.next.lexeme;
    var targetElement = _compilationUnit.declaredElement.library.getType(className);
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
  final Suppressions _ignores;
  final CompilationUnit _compilationUnit;

  _MirrorVisitor(this._compilationUnit, this._ignores);

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
              var targetElement = _compilationUnit.declaredElement.library.getType(className);
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
                int lineNumber = _compilationUnit.lineInfo.getLocation(node.offset).lineNumber;
                if (!_ignores.isSuppressedAt(OverrideHashcodeMethod.ruleId, lineNumber)) {
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
