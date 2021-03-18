import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:custom_code_analysis/src/logger/log.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/model/rule.dart';
import 'package:uuid/uuid.dart';

class ClickableWidgetIdMissing extends Rule {
  final CompilationUnit _compilationUnit;
  final ResolvedUnitResult analysisResult;
  String unitPath;

  static const ruleId = 'clickable-widget-uuid-missing';
  static const _comment = '快速添加';
  static const className = 'ClickableWidget';
  static const requiredField = 'uuid';
  static const _message = '$className缺少$requiredField参数';
  static const _correction = '$requiredField为$className必备参数，点击"$_comment"一键修复';

  ClickableWidgetIdMissing(this._compilationUnit, this.analysisResult) {
    unitPath = this._compilationUnit.declaredElement.source.fullName;
    logUtil.info("checker $unitPath");
  }

  int _getLineNumber(Token token) {
    return _compilationUnit.lineInfo.getLocation(token.offset).lineNumber;
  }

  String _generateReplacement(ArgumentList node) {
    int left = _getLineNumber(node.leftParenthesis);
    int right = _getLineNumber(node.rightParenthesis);
    String result;
    String _randomId = Uuid().v4().toString().replaceAll('-', '');

    String content = analysisResult.content;
    if (left == right) {
      result = '${content.substring(node.offset, node.offset + 1)}$requiredField: \'$_randomId\', ${content.substring(node.offset + 1, node.end)}';
    } else {
      result = '${content.substring(node.offset, node.offset + 1)}$requiredField: \'$_randomId\', ${content.substring(node.offset + 1, node.end)}';
    }
    return result;
  }

  List<ErrorIssue> errors() {
    final visitor = _MirrorVisitor();
    _compilationUnit.accept(visitor);
    return visitor.nodes.map(
      (node) {
        // node.arguments.add(astFactory.assignmentExpression("$requiredField", TokenType.AMPERSAND, "fdf"));
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
            _message,
            'code',
            correction: _correction,
            hasFix: true,
          ),
          replacement: _generateReplacement(node),
          fixes: codeIssueToAnalysisErrorFixes2(
            ErrorIssue(
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
                _message,
                'code',
                correction: _correction,
                hasFix: true,
              ),
              replacement: _generateReplacement(node),
            ),
            analysisResult,
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
              _comment,
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

final _annotatedClass = <String>[
  ClickableWidgetIdMissing.className,
  'RoundButton',
  'CircleButton'
  'AvatarPlayButton'
  'TEButton'
  'PlayButton'
];

class _MirrorVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <ArgumentList>[];

  Iterable<ArgumentList> get nodes => _nodes;

  // @override
  // void visitAnnotation(Annotation node) {
  //   super.visitAnnotation(node);
  //   if (node.name.name == 'Clickable') {
  //     if (node.arguments.arguments.isNotEmpty) {
  //       if (node.arguments.arguments.beginToken.lexeme == 'name') {
  //         if (!_annotatedClass.contains(node.arguments.arguments.endToken.lexeme)) {
  //           _annotatedClass.add(node.arguments.arguments.endToken.lexeme);
  //         }
  //       }
  //     }
  //   }
  // }

  @override
  void visitArgumentList(ArgumentList node) {
    super.visitArgumentList(node);
    // logUtil.info('name = $_annotatedClass');
    if (node.parent.childEntities.isNotEmpty) {
      // if (node.parent.beginToken.lexeme == ClickableWidgetIdMissing.className) {
      if (_annotatedClass.contains(node.parent.beginToken.lexeme)) {
        bool _isNeedFix = true;
        for (final item in node.arguments) {
          // logUtil.info('name = ${item.beginToken.lexeme}, requesn = ${ClickableWidgetIdMissing.requiredField}');
          if (item.beginToken.lexeme == ClickableWidgetIdMissing.requiredField) {
            _isNeedFix = false;
            break;
          }
        }
        if (_isNeedFix) {
          _nodes.add(node);
        }
      }
    }
  }
}
