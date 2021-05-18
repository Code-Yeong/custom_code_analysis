import 'package:analyzer_plugin/protocol/protocol_common.dart';

class Issue {
  Issue({
    this.hasFix,
    this.offset,
    this.length,
    this.line,
    this.column,
    this.message,
    this.code,
    this.correction,
    this.comment,
    this.replacement,
    this.errorSeverity,
    this.errorType,
  });

  final bool hasFix;

  final int offset;
  final int length;
  final int line;
  final int column;
  final String message;
  final String code;
  final String correction;
  final String comment;
  final String replacement;

  final AnalysisErrorSeverity errorSeverity;
  final AnalysisErrorType errorType;

  @override
  String toString() {
    return 'Issue{hasFix: $hasFix, offset: $offset, length: $length, line: $line, column: $column, message: $message, code: $code, correction: $correction, comment: $comment, replacement: $replacement, errorSeverity: $errorSeverity, errorType: $errorType}';
  }
}
