import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/reporter/reporter.dart';

class ConsoleReporter extends Reporter {
  @override
  List<String> report(List<Issue>? issueList) {
    List<String> _resultList = [];
    for (final issue in issueList!) {
      String _str =
          'type: ${issue.errorType!.name} · severity: ${issue.errorSeverity!.name} · line: ${issue.line} · column: ${issue.column} · message: ${issue.message} · file: ${issue.filePath}';
      _resultList.add(_str);
    }
    return _resultList;
  }
}
