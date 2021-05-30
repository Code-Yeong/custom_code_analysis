import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import 'arguments_parser.dart';

/// Umbrella method to run all checks
/// throws [InvalidArgumentException]
void validateArguments(ArgResults arguments) {
  checkRootFolderExistAndDirectory(arguments);
  checkPathsToAnalyzeNotEmpty(arguments);
  checkPathsExistAndDirectories(arguments);
}

void checkPathsToAnalyzeNotEmpty(ArgResults arguments) {
  if (arguments.rest.isEmpty) {

  }
}

void checkPathsExistAndDirectories(ArgResults arguments) {
  final rootFolderPath = arguments[rootFolderName] as String?;

  for (final relativePath in arguments.rest) {
    final absolutePath = path.join(rootFolderPath!, relativePath);
    if (!Directory(absolutePath).existsSync()) {

    }
  }
}

void checkRootFolderExistAndDirectory(ArgResults arguments) {
  final rootFolderPath = arguments[rootFolderName] as String;
  if (!Directory(rootFolderPath).existsSync()) {

  }
}
