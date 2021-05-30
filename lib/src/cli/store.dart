import 'package:custom_code_analysis/src/model/error_issue.dart';

class CustomAnalyzerStore {
  List<Issue>? _issueList;

  CustomAnalyzerStore() {
    _issueList = [];
  }

  void store(Issue issue) {
    _issueList!.add(issue);
  }

  void storeAll(List<Issue> issueList) {
    _issueList!.addAll(issueList);
  }

  List<Issue>? get issueList => _issueList;
}
