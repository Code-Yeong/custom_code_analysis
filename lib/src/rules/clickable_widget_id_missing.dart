import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_code_analysis/src/logger/log.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/model/rule.dart';
import 'package:uuid/uuid.dart';

List<String> existIdList = [];

class ClickableWidgetIdMissing extends Rule {
  ClickableWidgetIdMissing(
    String ruleId,
    ResolvedUnitResult analysisResult,
  ) : super(ruleId: ruleId, analysisResult: analysisResult);

  @override
  String get code => ruleId;

  @override
  String get comment => '快速添加';

  @override
  String get correction => '$requiredField为$className必备参数，点击"$comment"一键修复';

  @override
  String get message => '$className缺少$requiredField参数';

  @override
  String get methodName => null;

  static const annotation = 'Clickable';
  static const className = 'ClickableWidget';
  static const requiredField = 'uuid';

  int _getLineNumber(Token token) {
    return analysisResult.unit.lineInfo.getLocation(token.offset).lineNumber;
  }

  String _generateReplacement(InstanceCreationExpression node) {
    List<Expression> expressionList = [];
    var argumentList = node.argumentList.arguments;

    String result;
    String content = analysisResult?.content;
    if (node.constructorName.type?.name?.name == ClickableWidgetIdMissing.className) {
      List<String> _list = argumentList.map((e) => e.beginToken.lexeme).toList();
      if (_list.every((element) => element != ClickableWidgetIdMissing.requiredField)) {
        int left = _getLineNumber(node.argumentList.leftParenthesis);
        int right = _getLineNumber(node.argumentList.rightParenthesis);
        // logUtil.info('node = ,left = $left, ${node.argumentList.leftParenthesis.offset}, ${node}');
        String _randomId = Uuid().v4().toString().replaceAll('-', '');
        if (left == right) {
          result =
              '${node.constructorName}${content.substring(node.argumentList.leftParenthesis.offset, node.argumentList.leftParenthesis.offset + 1)}$requiredField: \'$_randomId\', ${content.substring(node.argumentList.leftParenthesis.offset + 1, node.end)}';
        } else {
          result =
              '${node.constructorName}${content.substring(node.argumentList.leftParenthesis.offset, node.argumentList.offset + 1)}$requiredField: \'$_randomId\', ${content.substring(node.argumentList.leftParenthesis.offset + 1, node.end)}';
        }
      }
    } else {
      for (final item in argumentList) {
        if ((item.beginToken.lexeme.endsWith('uuid') || item.beginToken.lexeme.endsWith('Uuid')) &&
            (item.endToken.lexeme == null ||
                item.endToken.lexeme == 'null' ||
                item.endToken.lexeme.replaceAll('\'', '') == '' ||
                item.endToken.lexeme.replaceAll('\'', '') == ' ' ||
                item.endToken.lexeme.isEmpty)) {
          expressionList.add(item);
        }
      }

      String _originSource = content.substring(node.argumentList.offset, node.argumentList.end);

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

      result = '${node.constructorName}$_originSource';
    }

    return result;
  }

  @override
  List<Issue> check() {
    final visitor = _ParameterVisitor();
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
              comment: comment,
              correction: correction,
              replacement: _generateReplacement(node),
              hasFix: false,
            ))
        .toList();
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
      bool _isNeedFix = false;

      if (node.constructorName.type?.name?.name == ClickableWidgetIdMissing.className) {
        List<String> _list = argumentList.map((e) => e.beginToken.lexeme).toList();
        if (_list.every((element) => element != ClickableWidgetIdMissing.requiredField)) {
          _isNeedFix = true;
        }
      } else {
        for (final item in argumentList) {
          if ((item.beginToken.lexeme.endsWith('uuid') || item.beginToken.lexeme.endsWith('Uuid')) &&
              (item.endToken.lexeme == null ||
                  item.endToken.lexeme == 'null' ||
                  item.endToken.lexeme.replaceAll('\'', '') == '' ||
                  item.endToken.lexeme.replaceAll('\'', '') == ' ' ||
                  item.endToken.lexeme.isEmpty)) {
            _isNeedFix = true;
          }
        }
      }
      if (_isNeedFix) {
        _nodes.add(node);
      }
    }
    super.visitInstanceCreationExpression(node);
  }
}
