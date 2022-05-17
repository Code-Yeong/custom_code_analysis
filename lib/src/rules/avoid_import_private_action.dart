import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
// import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:custom_code_analysis/src/logger/log.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/model/rule.dart';

class AvoidImportPrivateAction extends Rule {
  AvoidImportPrivateAction(String ruleId) : super(ruleId: ruleId);

  @override
  String? get code => ruleId;

  @override
  String get comment => '快速添加';

  @override
  String get correction => '移除import private action';

  @override
  String get message => '禁止 import 其他bloc private action';

  @override
  String get methodName => 'null';

  @override
  List<Issue> check(ResolvedUnitResult analysisResult) {
    List<Issue> issues = [];
    logUtil.info('check file: ${analysisResult.libraryElement.source.fullName}');
    final List<String> list = analysisResult.libraryElement.source.fullName.split('/');
    final int index = list.indexOf('lib');
    String packageName = '';
    if (index != -1 && index - 1 > 0) {
      packageName = list[index - 1];
    }

    if (packageName.isNotEmpty) {

      final visitor = _ImportVisitor(analysisResult: analysisResult, rule: this,packageName: packageName);
      analysisResult.unit.accept(visitor);
      return visitor.nodes
          .map((node) => Issue(
        errorSeverity: AnalysisErrorSeverity.INFO,
        errorType: AnalysisErrorType.HINT,
        offset: node.offset,
        length: node.length,
        line: analysisResult.unit.lineInfo.getLocation(node.offset).lineNumber,
        column: analysisResult.unit.lineInfo.getLocation(node.offset).columnNumber,
        endLine: analysisResult.unit.lineInfo.getLocation(node.end).lineNumber,
        endColumn: analysisResult.unit.lineInfo.getLocation(node.end).columnNumber,
        message: message,
        code: code,
        comment: comment,
        correction: correction,
        // replacement: _generateReplacement(node, analysisResult),
        hasFix: false,
        filePath: analysisResult.unit.declaredElement!.source.fullName,
      ))
          .toList();
    }

    return issues;

  }
}
class _ImportVisitor extends GeneralizingAstVisitor<void> {
  _ImportVisitor({this.rule, this.analysisResult,required this.packageName});

  final ResolvedUnitResult? analysisResult;
  final Rule? rule;

  final String packageName;

  final _nodes = <ImportDirective>[];

  Iterable<ImportDirective> get nodes => _nodes;

    @override
  void visitImportDirective(ImportDirective node) {
      logUtil.info('visitImportDirective: ${node.toString()}');
      logUtil.info('visitImportDirective: ${(node.element as ImportElement).library.name}');
      if (node.keyword.toString() == 'import' &&
          node.toString().contains('private_action.pb.dart') &&
          !node.toString().contains(packageName)) {
        logUtil.info(
            'import ${node.toString()}');
        _nodes.add(node);
      }
    super.visitImportDirective(node);
  }
}