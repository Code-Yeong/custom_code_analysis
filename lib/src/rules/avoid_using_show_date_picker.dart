import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/model/rule.dart';
import 'package:custom_code_analysis/src/utils/ingores.dart';

class AvoidUsingShowDatePicker extends Rule {
  final CompilationUnit _compilationUnit;
  final ResolvedUnitResult analysisResult;
  String unitPath;
  Suppressions _ignores;
  static const ruleId = 'avoid-using-show-date-picker';
  static const code = ruleId;
  static const methodName = 'showDatePicker';
  static const comment = '快速添加';
  static const message = '禁止使用原生$methodName方法';
  static const correction = '原生$methodName函数禁止调用';

  AvoidUsingShowDatePicker(this._compilationUnit, this.analysisResult) {
    unitPath = this._compilationUnit.declaredElement.source.fullName;
    _ignores = Suppressions(analysisResult.content, _compilationUnit.lineInfo);
  }

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
            hasFix: false,
          ),
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
}

class _MirrorVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];
  final Suppressions _ignores;
  final CompilationUnit _compilationUnit;

  _MirrorVisitor(this._compilationUnit, this._ignores);

  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    node.visitChildren(this);
    // logUtil.info('lineNumber = ${lineNumber}, ignored = ${_ignores.isSuppressedAt(AvoidUsingShowDatePicker.ruleId, lineNumber)}');
    if (node.methodName.name.contains(AvoidUsingShowDatePicker.methodName)) {
      int lineNumber = _compilationUnit.lineInfo.getLocation(node.offset).lineNumber;
      if (!_ignores.isSuppressedAt(AvoidUsingShowDatePicker.ruleId, lineNumber)) {
        _nodes.add(node);
      }
    }
  }
}
