import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/ignore_comments/ignore_info.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:custom_code_analysis/src/logger/log.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/model/rule.dart';
import 'package:custom_code_analysis/src/plugin/starter.dart';
import 'package:uuid/uuid.dart';

class ClickableWidgetIdMissing extends Rule {
  ClickableWidgetIdMissing(String ruleId) : super(ruleId: ruleId);

  @override
  String? get code => ruleId;

  @override
  String get comment => '快速添加';

  @override
  String get correction => '$requiredField为$className必备参数，点击"$comment"一键修复';

  @override
  String get message => '$className缺少$requiredField参数';

  @override
  String? get methodName => null;

  static const annotation = 'Clickable';
  static const className = 'ClickableWidget';
  static const requiredField = 'uuid';

  int _getLineNumber(Token token, ResolvedUnitResult analysisResult) {
    return analysisResult.unit!.lineInfo!.getLocation(token.offset).lineNumber;
  }

  String _generateReplacement(InstanceCreationExpression node, ResolvedUnitResult analysisResult) {
    List<Expression> expressionList = [];
    // 获取参数列表
    var argumentList = node.argumentList.arguments;

    String? result;

    // 拿到原始文本内容
    String? content = analysisResult.content;

    ClassElement? targetClazz;
    for (final lib in analysisResult.libraryElement.importedLibraries) {
      for (final unit in lib.units) {
        targetClazz = unit.getType(node.constructorName.type.name.name);
        if (targetClazz != null) {
          break;
        }
      }
    }
    List<String> definedNameList = targetClazz?.fields?.map((e) => e.name)?.toList() ?? [];
    List<String> _nameList = argumentList.map((e) => e.beginToken.lexeme).toList();
    for (final name in definedNameList) {
      if (name.toLowerCase().endsWith('uuid') && !_nameList.contains(name)) {
        int left = _getLineNumber(node.argumentList.leftParenthesis, analysisResult);
        int right = _getLineNumber(node.argumentList.rightParenthesis, analysisResult);
        // logUtil.info('node = ,left = $left, ${node.argumentList.leftParenthesis.offset}, ${node}');
        String _randomId = Uuid().v4().toString().replaceAll('-', '');
        if (left == right) {
          result =
              '${node.constructorName}${content!.substring(node.argumentList.leftParenthesis.offset, node.argumentList.leftParenthesis.offset + 1)}$requiredField: \'$_randomId\', ${content.substring(node.argumentList.leftParenthesis.offset + 1, node.end)}';
        } else {
          result =
              '${node.constructorName}${content!.substring(node.argumentList.leftParenthesis.offset, node.argumentList.offset + 1)}$requiredField: \'$_randomId\', ${content.substring(node.argumentList.leftParenthesis.offset + 1, node.end)}';
        }
      }
    }

    if (result != null) {
      return result;
    }

    // // 如果是 ClickableWidget
    // if (node.constructorName.type?.name?.name == ClickableWidgetIdMissing.className) {
    //   // 拿到所有参数名
    //   List<String> _list = argumentList.map((e) => e.beginToken.lexeme).toList();
    //   if (_list.every((element) => element != ClickableWidgetIdMissing.requiredField)) {
    //     int left = _getLineNumber(node.argumentList.leftParenthesis, analysisResult);
    //     int right = _getLineNumber(node.argumentList.rightParenthesis, analysisResult);
    //     // logUtil.info('node = ,left = $left, ${node.argumentList.leftParenthesis.offset}, ${node}');
    //     String _randomId = Uuid().v4().toString().replaceAll('-', '');
    //     if (left == right) {
    //       result =
    //           '${node.constructorName}${content.substring(node.argumentList.leftParenthesis.offset, node.argumentList.leftParenthesis.offset + 1)}$requiredField: \'$_randomId\', ${content.substring(node.argumentList.leftParenthesis.offset + 1, node.end)}';
    //     } else {
    //       result =
    //           '${node.constructorName}${content.substring(node.argumentList.leftParenthesis.offset, node.argumentList.offset + 1)}$requiredField: \'$_randomId\', ${content.substring(node.argumentList.leftParenthesis.offset + 1, node.end)}';
    //     }
    //   }
    // } else {
    //
    // }

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

    String _originSource = content!.substring(node.argumentList.offset, node.argumentList.end);

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

    return result;
  }

  @override
  List<Issue> check(ResolvedUnitResult analysisResult) {
    logUtil.info('check file: ${analysisResult.libraryElement.source.fullName}');
    final visitor = _ParameterVisitor(analysisResult: analysisResult, rule: this);
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
              message: generateMessage(node),
              code: code,
              comment: comment,
              correction: correction,
              replacement: _generateReplacement(node, analysisResult),
              hasFix: false,
              filePath: analysisResult.unit!.declaredElement!.source.fullName,
            ))
        .toList();
  }

  String generateMessage(InstanceCreationExpression node) {
    String message = '';
    var argumentList = node.argumentList.arguments;

    if (argumentList.isEmpty) {
      /// 参数列表为空，肯定没有uuid，需要修复
      message = '没有uuid';
    } else if (argumentList.map((e) => e.beginToken.lexeme).toList().every((element) => !element.endsWith('uuid'))) {
      /// 没有找到任何以uuid结尾的字段名
      message = '参数列表为空，缺少uuid';
    } else {
      /// 遍历每一个属性
      for (final item in argumentList) {
        /// 属性名以 uuid 或 Uuid 结尾
        bool _hasFindTargetField = item.beginToken.lexeme.endsWith('uuid') || item.beginToken.lexeme.endsWith('Uuid');

        /// 属性值等于 null|'null'|''|' '
        bool _isInValidValue = item.endToken.lexeme == null ||
            item.endToken.lexeme == 'null' ||
            item.endToken.lexeme.replaceAll('\'', '') == '' ||
            item.endToken.lexeme.replaceAll('\'', '') == ' ' ||
            item.endToken.lexeme.isEmpty;

        if (_hasFindTargetField && _isInValidValue) {
          /// 字段名符合条件、字段值不符合条件
          message = 'uuid值不符合条件';
        } else if (_hasFindTargetField && !_isInValidValue) {
          /// 字段名、字段值都符合条件
          if (existIdList.contains(item.endToken.lexeme)) {
            /// uuid重复了
            message = 'uuid重复了';
          }
        }
      }
    }
    return message;
  }
}

class _ParameterVisitor extends GeneralizingAstVisitor<void> {
  _ParameterVisitor({this.rule, this.analysisResult});

  final ResolvedUnitResult? analysisResult;
  final Rule? rule;

  final _nodes = <InstanceCreationExpression>[];

  Iterable<InstanceCreationExpression> get nodes => _nodes;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    var _metaData = node.staticType!.element!.metadata;
    bool _isTargetAnnotation = false;

    int lineNumber = analysisResult!.unit!.lineInfo!.getLocation(node.offset).lineNumber;
    var ignoreInfo = IgnoreInfo.forDart(analysisResult!.unit!, analysisResult!.content!);

    /// 判断是否被 @Clickable 标记
    for (final item in _metaData) {
      if (item.computeConstantValue()?.type?.getDisplayString(withNullability: false) == ClickableWidgetIdMissing.annotation) {
        _isTargetAnnotation = true;
        break;
      }
    }

    /// 判断是否是 ClickableWidget
    if (node.constructorName.type.name.name == ClickableWidgetIdMissing.className) {
      _isTargetAnnotation = true;
    }

    /// 判断是否忽略
    if (ignoreInfo.ignoredAt(rule!.code!.replaceAll('-', '_'), lineNumber)) {
      _isTargetAnnotation = false;
    }

    /// 找到了需要处理的目标节点
    if (_isTargetAnnotation) {
      var argumentList = node.argumentList.arguments;

      /// 标记是否需要修复
      bool _isNeedFix = false;

      if (argumentList.isEmpty) {
        /// 参数列表为空，肯定没有uuid，需要修复
        _isNeedFix = true;
      } else if (argumentList.map((e) => e.beginToken.lexeme).toList().every((element) => !element.endsWith('uuid'))) {
        /// 没有找到任何以uuid结尾的字段名
        _isNeedFix = true;
      } else {
        /// 遍历每一个属性
        for (final item in argumentList) {
          /// 属性名以 uuid 或 Uuid 结尾
          bool _hasFindTargetField = item.beginToken.lexeme.endsWith('uuid') || item.beginToken.lexeme.endsWith('Uuid');

          /// 属性值等于 null|'null'|''|' '
          bool _isInValidValue = item.endToken.lexeme == null ||
              item.endToken.lexeme == 'null' ||
              item.endToken.lexeme.replaceAll('\'', '') == '' ||
              item.endToken.lexeme.replaceAll('\'', '') == ' ' ||
              item.endToken.lexeme.isEmpty;

          if (_hasFindTargetField && _isInValidValue) {
            /// 字段名符合条件、字段值不符合条件
            _isNeedFix = true;
          } else if (_hasFindTargetField && !_isInValidValue) {
            /// 字段名、字段值都符合条件
            if (existIdList.contains(item.endToken.lexeme)) {
              /// uuid重复了
              _isNeedFix = true;
            } else {
              /// uuid不重复，加入列表中记录下来
              existIdList.add(item.endToken.lexeme);
            }
          }
        }
      }

      if (_isNeedFix) {
        /// 需要修复，记录节点
        _nodes.add(node);
      }
    }
    super.visitInstanceCreationExpression(node);
  }
}
