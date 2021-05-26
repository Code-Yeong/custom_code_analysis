import 'dart:io';

import 'package:args/args.dart';

const usageHeader = 'Usage: metrics [options...] <directories>';
const helpFlagName = 'help';
const reporterName = 'reporter';
const verboseName = 'verbose';
const gitlabCompatibilityName = 'gitlab';
const ignoredFilesName = 'ignore-files';
const rootFolderName = 'root-folder';
const setExitOnViolationLevel = 'set-exit-on-violation-level';

ArgParser argumentsParser() {
  final parser = ArgParser();

  _appendHelpOption(parser);
  parser.addSeparator('');
  _appendReporterOption(parser);
  parser.addSeparator('');
  _appendRootOption(parser);
  _appendExcludesOption(parser);
  parser.addSeparator('');
  _appendExitOption(parser);

  return parser;
}

void _appendHelpOption(ArgParser parser) {
  parser.addFlag(
    helpFlagName,
    abbr: 'h',
    help: 'Print this usage information.',
    negatable: false,
  );
}

void _appendReporterOption(ArgParser parser) {
  parser
    ..addOption(
      reporterName,
      abbr: 'r',
      help: 'The format of the output of the analysis',
      valueHelp: 'console',
      allowed: ['console', 'github', 'json', 'html', 'codeclimate'],
      defaultsTo: 'console',
    )
    ..addFlag(
      verboseName,
      help: 'Additional flag for Console reporter',
      negatable: false,
    )
    ..addFlag(
      gitlabCompatibilityName,
      help:
          'Additional flag for Code Climate reporter to report in GitLab Code Quality format',
      negatable: false,
    );
}

// @immutable
// class _MetricOption<T> {
//   final String name;
//   final String help;
//   final T defaultValue;
//
//   const _MetricOption(this.name, this.help, this.defaultValue);
// }

void _appendRootOption(ArgParser parser) {
  parser.addOption(
    rootFolderName,
    help: 'Root folder',
    valueHelp: './',
    defaultsTo: Directory.current.path,
  );
}

void _appendExcludesOption(ArgParser parser) {
  parser.addOption(
    ignoredFilesName,
    help: 'Filepaths in Glob syntax to be ignored',
    valueHelp: '{/**.g.dart,/**.template.dart}',
    defaultsTo: '{/**.g.dart,/**.template.dart}',
  );
}

void _appendExitOption(ArgParser parser) {
  parser.addOption(
    setExitOnViolationLevel,
    allowed: ['noted', 'warning', 'alarm'],
    valueHelp: 'warning',
    help:
        'Set exit code 2 if code violations same or higher level than selected are detected',
  );
}
