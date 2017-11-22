import 'dart:io';

import 'package:revolver/revolver.dart' show RevolverConfiguration;
import 'package:revolver/src/project_template.dart';
import 'package:revolver/src/file_util.dart';

final ProjectTemplate _gitProject = new GitProjectTemplate('.gitignore', ['.git/**']);
final ProjectTemplate _dartProject = new DartProjectTemplate();

bool _checkIsRequestedExtension(String filePath) {
  List<String> requestedExtensions = RevolverConfiguration.extList;

  // Default to returning everything or if this is a directory
  if (requestedExtensions == null ||
      requestedExtensions.length == 0 ||
      FileSystemEntity.isDirectorySync(filePath)) {
    return true;
  }

  for (String ext in requestedExtensions) {

    if (filePath.endsWith('.${ext}')) {
        return true;
    }
  }
  return false;
}

bool _checkIsIgnoredFile(String filePath) {
  List<ProjectTemplate> projectTemplates = [];

  if (RevolverConfiguration.isGitProject) {
    projectTemplates.add(_gitProject);
  }

  if (RevolverConfiguration.doIgnoreDart) {
    projectTemplates.add(_dartProject);
  }

  return projectTemplates.any((projectTemplate) => projectTemplate.checkIgnoreFile(filePath));
}

checkDoWatchFile(filePath) {
  filePath = convertToRelativePath(filePath);
  return _checkIsRequestedExtension(filePath) && !_checkIsIgnoredFile(filePath);
}
