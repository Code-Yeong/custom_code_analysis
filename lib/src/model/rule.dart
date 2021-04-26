import 'package:custom_code_analysis/src/model/error_issue.dart';

abstract class Rule{
  Iterable<ErrorIssue> errors();
}