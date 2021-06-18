import 'package:custom_code_analysis/src/logger/log.dart';
import 'package:yaml/yaml.dart';

const String analysisOptionsFileName = 'analysis_options.yaml';

const _rootKey = 'custom_code_analysis';
const _customExcludeKey = 'exclude';
const _rulesKey = 'rules';

class AnalysisOptions {
  static AnalysisOptions fromYamlMap(YamlMap yamlMap) {
    YamlMap? map = yamlMap[_rootKey];
    // logUtil.info('parse map = $map, origin = $yamlMap');
    if(map == null){
      return AnalysisOptions(
        rules: [],
        excludes: [],
      );
    }
    return AnalysisOptions(
      rules: List<String>.from(map[_rulesKey]?.toList() ?? []),
      excludes: List<String>.from(map[_customExcludeKey]?.toList() ?? []),
    );
  }

  AnalysisOptions({this.excludes, this.rules});

  final List<String>? excludes;
  final List<String>? rules;
}
