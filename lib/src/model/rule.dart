import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:custom_code_analysis/src/visitors/code_issue_visitor.dart';

import 'error_issue.dart';

abstract class Rule {
  Rule({this.ruleId});

  Iterable<Issue> check(ResolvedUnitResult analysisResult) {
    final visitor = CodeIssueVisitor(analysisResult: analysisResult, rule: this);
    analysisResult.unit.accept(visitor);
    return visitor.nodes
        .map((node) => Issue(
              errorSeverity: AnalysisErrorSeverity.INFO,
              errorType: AnalysisErrorType.HINT,
              offset: node.offset,
              length: node.length,
              line: analysisResult.unit.lineInfo!.getLocation(node.offset).lineNumber,
              column: analysisResult.unit.lineInfo!.getLocation(node.offset).columnNumber,
              endLine: analysisResult.unit.lineInfo!.getLocation(node.end).lineNumber,
              endColumn: analysisResult.unit.lineInfo!.getLocation(node.end).columnNumber,
              message: message,
              code: code,
              correction: correction,
              hasFix: false,
              filePath: analysisResult.unit.declaredElement!.source.fullName,
            ))
        .toList();
  }

  final String? ruleId;

  String? get code;

  String get correction;

  String get message;

  String get comment;

  String? get methodName;
}
