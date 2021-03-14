// import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer_plugin/protocol/protocol_common.dart';
// import 'package:custom_code_analysis/rules/clickable_widget_id_missing.dart';
// import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
// import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
// import 'package:analyzer/dart/analysis/results.dart';
//
// AnalysisError analysisErrorFor(String path, ErrorIssue issue, CompilationUnit unit) {
//   final offsetLocation = unit.lineInfo.getLocation(issue.offset);
//   return AnalysisError(
//     issue.analysisErrorSeverity,
//     issue.analysisErrorType,
//     Location(
//       path,
//       issue.offset,
//       issue.length,
//       offsetLocation.lineNumber,
//       offsetLocation.columnNumber,
//     ),
//     // issue.message,
//     '${issue.offset} =--= ${issue.length}',
//     issue.code,
//     hasFix: false,
//     // correction: issue.correction,
//     correction: '${issue.offset} == ${issue.length}',
//   );
// }
//
//
