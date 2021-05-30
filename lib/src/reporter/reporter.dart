import 'package:custom_code_analysis/src/model/error_issue.dart';

abstract class Reporter {
  List<String> report(List<Issue>? issueList);
}
