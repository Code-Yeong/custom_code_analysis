import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_code_analysis/src/model/error_issue.dart';

AnalysisError codeIssueToAnalysisError(Issue issue, ResolvedUnitResult analysisResult) {
  return AnalysisError(
    issue.errorSeverity!,
    issue.errorType!,
    Location(
      analysisResult.unit!.declaredElement!.source.fullName,
      issue.offset!,
      issue.length!,
      issue.line!,
      issue.column!,
      issue.endLine!,
      issue.endColumn!,
    ),
    issue.message!,
    issue.code!,
    correction: issue.correction,
    hasFix: issue.hasFix,
  );
}

List<AnalysisErrorFixes> codeIssueToAnalysisErrorFixes(List<Issue> issueList, ResolvedUnitResult analysisResult) {
  return issueList.map(
    (issue) => AnalysisErrorFixes(
      codeIssueToAnalysisError(issue, analysisResult),
      fixes: [
        if (issue.correction != null)
          PrioritizedSourceChange(
            99,
            SourceChange(
              issue.comment!,
              edits: [
                SourceFileEdit(
                  analysisResult.libraryElement.source.fullName,
                  analysisResult.libraryElement.source.modificationStamp,
                  edits: [
                    SourceEdit(
                      issue.offset!,
                      issue.length!,
                      issue.replacement!,
                    ),
                  ],
                ),
              ],
              // selection: Position(unitResult.libraryElement.source.fullName, issue.offset),
            ),
          ),
      ],
    ),
  ) as List<AnalysisErrorFixes>;
}
