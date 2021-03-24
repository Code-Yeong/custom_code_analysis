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

  final String debugContent;

  static const ruleId = 'clickable-widget-uuid-missing';
  static const _comment = '快速添加';
  static const annotation = 'Clickable';
  static const className = 'ClickableWidget';
  static const requiredField = 'uuid';
  static const _message = '$className缺少$requiredField参数';
  static const _correction = '$requiredField为$className必备参数，点击"$_comment"一键修复';

  ClickableWidgetIdMissing(this._compilationUnit, this.analysisResult, {this.debugContent}) {
    unitPath = this._compilationUnit.declaredElement.source.fullName;
    logUtil.info("checker $unitPath");
  }

  // int _getLineNumber(Token token) {
  //   return _compilationUnit.lineInfo.getLocation(token.offset).lineNumber;
  // }

  String get _code => Uuid().v4().toString().replaceAll('-', '');

  String _generateReplacement(InstanceCreationExpression node) {
    List<Expression> expressionList = [];
    var argumentList = node.argumentList.arguments;
    for (final item in argumentList) {
      if (item.beginToken.lexeme.endsWith('uuid') && item.endToken.lexeme?.length != 34) {
        expressionList.add(item);
      }
    }
    // String content = analysisResult?.content ?? debugContent;

    String content = analysisResult?.content ?? debugContent;

    // String _originSource = node.argumentList.toString();
    String _originSource = content.substring(node.argumentList.offset, node.argumentList.end);

    // String _originSource = node.argumentList.toString();
    for (final obj in expressionList) {
      String _p1 = '${obj.beginToken.lexeme}: ${obj.endToken.lexeme}';
      String _p2 = '${obj.beginToken.lexeme}:${obj.endToken.lexeme}';
      String _randomId = Uuid().v4().toString().replaceAll('-', '');
      String _replaceStr = '${obj.beginToken.lexeme}: \'$_randomId\'';
      if (_originSource.contains(_p1)) {
        _originSource = _originSource.replaceAll(_p1, _replaceStr);
      } else if (_originSource.contains(_p2)) {
        _originSource = _originSource.replaceAll(_p2, _replaceStr);
      }
    }

    String result = '${node.constructorName}$_originSource';

    // return content;

    // int left = _getLineNumber(node.argumentList.leftParenthesis);
    // int right = _getLineNumber(node.argumentList.rightParenthesis);
    // logUtil.info('node = ,left = $left, ${node.argumentList.leftParenthesis.offset}, ${node}');
    // return '';
    // String result;

    // if (left == right) {
    //   result =
    //       '${node.constructorName}${content.substring(node.argumentList.leftParenthesis.offset, node.argumentList.leftParenthesis.offset + 1)}$requiredField: \'$_randomId\', ${content.substring(node.argumentList.leftParenthesis.offset + 1, node.end)}';
    // } else {
    //   result =
    //       '${node.constructorName}${content.substring(node.argumentList.leftParenthesis.offset, node.argumentList.offset + 1)}$requiredField: \'$_randomId\', ${content.substring(node.argumentList.leftParenthesis.offset + 1, node.end)}';
    // }
    // logUtil.info('result = $result');
    return result;
  }

  List<ErrorIssue> errors() {
    // final visitor = _MirrorVisitor();
    final visitor = _ParameterVisitor();
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
            _code,
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
                _code,
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
    // return null;
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

class _ParameterVisitor extends GeneralizingAstVisitor<void> {
  final _nodes = <InstanceCreationExpression>[];

  Iterable<InstanceCreationExpression> get nodes => _nodes;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    var _metaData = node.staticType.element.metadata;
    bool _isTargetAnnotation = false;
    for (final item in _metaData) {
      if (item?.computeConstantValue()?.type?.getDisplayString(withNullability: false) == ClickableWidgetIdMissing.annotation) {
        _isTargetAnnotation = true;
        break;
      }
    }
    if (node.constructorName.type?.name?.name == ClickableWidgetIdMissing.className) {
      _isTargetAnnotation = true;
    }
    if (_isTargetAnnotation) {
      var argumentList = node.argumentList.arguments;
      // bool _isNeedFix = true;
      bool _isNeedFix = false;
      for (final item in argumentList) {
        // logUtil.info(
        //     'class = ${node.constructorName.type.name.name}: ${item}-  ${node.offset} - ${item.beginToken.lexeme} --: ${item.beginToken.lexeme.endsWith('uuid')}: ${item.endToken.lexeme}, ${item.endToken.lexeme?.length != 34}');
        // if (item.beginToken.lexeme == ClickableWidgetIdMissing.requiredField) {
        //   _isNeedFix = false;
        //   break;
        // }
        if (item.beginToken.lexeme.endsWith('uuid') &&
            (item.endToken.lexeme == null ||
                item.endToken.lexeme == 'null' ||
                item.endToken.lexeme.replaceAll('\'', '') == '' ||
                item.endToken.lexeme.replaceAll('\'', '') == ' ' ||
                item.endToken.lexeme.isEmpty)) {
          _isNeedFix = true;
        }
      }
      if (_isNeedFix) {
        _nodes.add(node);
      }
    }
    super.visitInstanceCreationExpression(node);
  }
}
