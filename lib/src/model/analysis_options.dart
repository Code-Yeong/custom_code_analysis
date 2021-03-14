import 'package:custom_code_analysis/src/logger/log.dart';

const String analysisOptionsFileName = 'analysis_options.yaml';

const _rootKey = 'custom_code_analysis';
const _customExcludeKey = 'exclude';
const _rulesKey = 'rules';
// const _antiPatternsKey = 'anti-patterns';

// const _analyzerKey = 'analyzer';
// const _excludeKey = 'exclude';

class AnalysisOptions {
  static AnalysisOptions fromMap(Map<String, Object> map) {
    return AnalysisOptions(
      rules: _readRules(map[_rootKey] ?? {}),
      excludes: _readExcludes(map[_rootKey] ?? {}),
    );
  }

  AnalysisOptions({this.excludes, this.rules});

  final List<dynamic> excludes;
  final List<dynamic> rules;

  static List<dynamic> _readExcludes(Map<String, Object> map) {
    logUtil.info('_readExcludes ');
    if (map == null) {
      return [];
    }
    var result = List.from(map[_customExcludeKey] ?? []);
    logUtil.info('_readExcludes = $result');
    return result;
  }

  static List<dynamic> _readRules(Map<String, Object> map) {
    logUtil.info('_readRules ');
    if (map == null) {
      return [];
    }
    List<String> ruleList = List.from(map[_rulesKey] ?? []);

    logUtil.info('_readRules = $ruleList');
    return ruleList;
  }
}
