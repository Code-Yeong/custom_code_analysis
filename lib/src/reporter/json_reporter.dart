import 'package:custom_code_analysis/src/model/error_issue.dart';
import 'package:custom_code_analysis/src/reporter/reporter.dart';

class JsonReporter extends Reporter {
  @override
  List<String> report(List<Issue>? issueList) {
    List<String> _resultList = [];
    for (final issue in issueList!) {
      var _json = {
        'type': issue.errorType!.name,
        'severity': issue.errorSeverity!.name,
        'line': issue.line,
        'column': issue.column,
        'message': issue.message,
        'file': issue.filePath
      };
      _resultList.add(_json.toString());
    }
    return _resultList;
  }
}
