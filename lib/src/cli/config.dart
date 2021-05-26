import 'package:custom_code_analysis/src/model/analysis_options.dart';
import 'package:meta/meta.dart';

/// Class representing config
@immutable
class Config {
  final Iterable<String> excludePatterns;
  final Iterable<String> rules;

  const Config({
    @required this.excludePatterns,
    @required this.rules,
  });

  factory Config.fromAnalysisOptions(AnalysisOptions options) {
    return Config(
      excludePatterns: options.excludes,
      rules: options.rules,
    );
  }
}
