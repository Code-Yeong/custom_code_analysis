import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_code_analysis/src/visitors/code_issue_visitor.dart';

import 'error_issue.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';

abstract class Rule {
  Rule({this.ruleId, this.analysisResult});

  Iterable<Issue> check() {
    final visitor = CodeIssueVisitor(analysisResult: analysisResult, rule: this);
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
              correction: correction,
              hasFix: false,
            ))
        .toList();
  }

  final String ruleId;

  final ResolvedUnitResult analysisResult;

  String get code;

  String get correction;

  String get message;

  String get comment;

  String get methodName;
}
