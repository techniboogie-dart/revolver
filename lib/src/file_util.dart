import 'dart:io';

import 'package:revolver/revolver.dart' show RevolverConfiguration;

String convertToRelativePath(filePath) {
  String basePath;

  if (RevolverConfiguration.baseDir != null) {
    basePath = new Directory(RevolverConfiguration.baseDir).path;
  }
  else {
    basePath = Directory.current.path;
  }

  basePath = '${basePath}${Platform.pathSeparator}';

  return filePath.replaceAll(basePath, '');
}
