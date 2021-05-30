import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/src/ignore_comments/ignore_info.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/model/rule.dart';

class OverrideHashcodeMethod extends Rule {
  OverrideHashcodeMethod(String ruleId) : super(ruleId: ruleId);

  @override
  String? get code => ruleId;

  @override
  String get comment => '快速修复';

  @override
  String get correction => '$methodName中要包含每个field';

  @override
  String get message => '$methodName不全';

  @override
  String get methodName => 'hashCode';

  @override
  Iterable<Issue> check(ResolvedUnitResult analysisResult) {
    final visitor = _MirrorVisitor(analysisResult, this);
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
              // message: message,
              message: generateMessage(node as ClassDeclaration, analysisResult),
              code: code,
              correction: generateMessage(node, analysisResult),
              replacement: generateReplacement(node, analysisResult),
              hasFix: false,
              filePath: analysisResult.unit!.declaredElement!.source.fullName,
            ))
        .toList();
  }

  String generateReplacement(ClassDeclaration node, ResolvedUnitResult analysisResult) {
    String fixStr = '';

    bool _isNotExist = node.members.every((item) {
      try {
        return item.metadata.single.toString() != '@override' || (item.metadata.single.toString() == '@override' && item?.declaredElement?.name != 'hashCode');
      } catch (e) {
        return true;
      }
    });
    if (_isNotExist) {
      List<String> _filedNameList = [];
      for (final obj in node.members) {
        if (obj.beginToken.lexeme == 'final') {
          _filedNameList.add('${obj.endToken.previous!.lexeme}.hashCode');
        }
      }
      fixStr = 'int get hashCode => ${_filedNameList.join(' ^ ')};';
      return fixStr;
    } else {
      for (final item in node.members) {
        try {
          if (item.metadata.single.toString() == '@override') {
            if (item?.declaredElement?.name == 'hashCode') {
              // print('item = ${item}');
            }
          }
        } catch (e) {}
      }
    }

    // var className = node.parent.parent.beginToken.next.lexeme;
    // var targetElement = analysisResult.unit.declaredElement.library.getType(className);
    // if (targetElement.supertype.getDisplayString(withNullability: false) == 'ReduxViewModel') {
    //   var fields = targetElement.unnamedConstructor.parameters;
    //   for (final field in fields) {
    //     String displayName = '${field.displayName}.hashCode';
    //     fixStr = '$fixStr ^ $displayName';
    //   }
    // }
    //
    // fixStr = fixStr.replaceRange(0, 3, '');
    // print('fixStr = $fixStr');
    return fixStr;
  }
}

String generateMessage(ClassDeclaration node, ResolvedUnitResult analysisResult) {
  String _message = '缺少hashCode';

  List<String> _filedNameList = [];
  for (final obj in node.members) {
    if (obj.beginToken.lexeme == 'final') {
      _filedNameList.add('${obj.endToken.previous!.lexeme}.hashCode');
    }
  }

  for (final item in node.members) {
    try {
      if (item.metadata.single.toString() == '@override') {
        if (item?.declaredElement?.name == 'hashCode') {
          List<String> _missingFiledList = [];
          for (final obj in _filedNameList) {
            if (!item.toString().contains(obj)) {
              _missingFiledList.add(obj);
            }
          }
          if (_missingFiledList.isNotEmpty) {
            _message = '缺少 ${_missingFiledList.join(',')}';
          }
        }
      }
    } catch (e) {}
  }
  return _message;
}

class _MirrorVisitor extends RecursiveAstVisitor<void> {
  final _nodes = <AstNode>[];
  final ResolvedUnitResult analysisResult;
  final Rule rule;

  _MirrorVisitor(this.analysisResult, this.rule);

  Iterable<AstNode> get nodes => _nodes;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    String superClassName = node.declaredElement!.supertype!.getDisplayString(withNullability: false);
    if (superClassName != null && superClassName == 'ReduxViewModel') {
      int lineNumber = analysisResult.unit!.lineInfo!.getLocation(node.offset).lineNumber;
      var ignoreInfo = IgnoreInfo.forDart(analysisResult.unit!, analysisResult.content!);
      if (ignoreInfo.ignoredAt(rule.ruleId!.replaceAll('-', '_'), lineNumber)) {
        return;
      }
      bool _isNeedFix = true;

      List<String> _filedNameList = [];
      for (final obj in node.members) {
        if (obj.beginToken.lexeme == 'final') {
          _filedNameList.add('${obj.endToken.previous!.lexeme}.hashCode');
        }
      }

      for (final item in node.members) {
        try {
          if (item.metadata.single.toString() == '@override') {
            if (item?.declaredElement?.name == 'hashCode') {
              _isNeedFix = _filedNameList.any((element) => !item.toString().contains(element));
            }
          }
        } catch (e) {}
      }
      if (_isNeedFix) {
        _nodes.add(node);
      }
    }

    super.visitClassDeclaration(node);
  }
}
