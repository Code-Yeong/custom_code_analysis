import 'package:analyzer/source/line_info.dart';

class Suppressions {
  Suppressions(String content, LineInfo info) {
    for (final match in _ignoreMatchers.allMatches(content)) {
      final ids = match.group(1).split(',').map(_canonicalize);
      final location = info.getLocation(match.start);
      final lineNumber = location.lineNumber;
      final beforeMatch = content.substring(
        info.getOffsetOfLine(lineNumber - 1),
        info.getOffsetOfLine(lineNumber - 1) + location.columnNumber - 1,
      );

      // If comment sits next to code, so it refers to its own line, otherwise it refers to the next line.
      final ignoredNextLine = beforeMatch.trim().isEmpty;
      _ignoreMap
          .putIfAbsent(
            ignoredNextLine ? lineNumber + 1 : lineNumber,
            () => <String>[],
          )
          .addAll(ids);
    }

    for (final match in _ignoreForFileMatcher.allMatches(content)) {
      _ignoreForFileSet.addAll(match.group(1).split(',').map(_canonicalize));
    }
  }

  static final _ignoreMatchers = RegExp('//[ ]*ignore:(.*)', multiLine: true);

  static final _ignoreForFileMatcher = RegExp('//[ ]*ignore_for_file:(.*)', multiLine: true);

  final _ignoreMap = <int, List<String>>{};
  final _ignoreForFileSet = <String>{};

  /// Checks [id] globally suppressed
  bool isSuppressed(String id) => _ignoreForFileSet.contains(_canonicalize(id));

  /// Checks [id] suppressed for [lineIndex]
  bool isSuppressedAt(String id, int lineIndex) => isSuppressed(id) || (_ignoreMap[lineIndex]?.contains(_canonicalize(id)) ?? false);

  String _canonicalize(String ruleId) => ruleId.trim().toLowerCase();
}
