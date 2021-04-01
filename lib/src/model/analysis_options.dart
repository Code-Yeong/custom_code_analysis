import 'package:custom_code_analysis/src/logger/log.dart';
import 'package:yaml/yaml.dart';
import 'package:analyzer/src/util/yaml.dart';

const String analysisOptionsFileName = 'analysis_options.yaml';

const _rootKey = 'custom_code_analysis';
const _customExcludeKey = 'exclude';
const _rulesKey = 'rules';
// const _antiPatternsKey = 'anti-patterns';

// const _analyzerKey = 'analyzer';
// const _excludeKey = 'exclude';

class AnalysisOptions {
  static AnalysisOptions fromYamlMap(YamlMap yamlMap) {
    return AnalysisOptions(
      rules: getKey(yamlMap, _rulesKey).value,
      excludes: getKey(yamlMap, _customExcludeKey).value,
    );
  }

  AnalysisOptions({this.excludes, this.rules});

  final List<dynamic> excludes;
  final List<dynamic> rules;
}
