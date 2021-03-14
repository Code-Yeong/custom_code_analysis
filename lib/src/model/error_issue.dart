import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;

class ErrorIssue {
  final plugin.AnalysisError error;
  final String replacement;
  plugin.AnalysisErrorFixes fixes;

  ErrorIssue({
    this.error,
    this.replacement,
    this.fixes,
  });
}
