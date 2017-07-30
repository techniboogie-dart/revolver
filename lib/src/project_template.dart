import 'dart:io' show File;

import 'package:glob/glob.dart' show Glob;

abstract class ProjectTemplate {
  bool checkIgnoreFile(String filePath);
}

class GitProjectTemplate implements ProjectTemplate {
  List<Glob> ignoreFileGlobs;

  GitProjectTemplate(String ignoreFileName, [List<String> filePaths]) {
    List<String> globFileExpressions = filePaths.toList();

    if (ignoreFileName != null) {
      globFileExpressions.addAll(new File(ignoreFileName).readAsLinesSync());
    }

    this.ignoreFileGlobs = globFileExpressions
    .where((fileExp) => fileExp.trim().length > 0)
    .map((file) {
      return new Glob(file);
    });
  }

  bool checkIgnoreFile(String filePath) {
    return ignoreFileGlobs.any((glob) => glob.matches(filePath));
  }
}

class DartProjectTemplate implements ProjectTemplate {
  final List<Glob> ignoreFileGlobs = [
    new Glob('.pub/**'),
    new Glob('.packages')
  ];

  bool checkIgnoreFile(String filePath) {

    return ignoreFileGlobs.any((glob) {
      glob.matches(filePath);
    });
  }
}
