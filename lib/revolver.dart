import 'dart:isolate';
import 'dart:io';
import 'dart:async';

import 'package:ansicolor/ansicolor.dart';

import 'package:revolver/src/file_watcher.dart';

class Configuration {
  String baseDir;
  List<String> extList;
  String bin;
  List<String> binArgs;

  Configuration(this.baseDir, this.extList, this.bin, this.binArgs);
}

void start(Configuration config) {

  print('Watching for changes ${config.extList}');

  Isolate.spawnUri(
    new Uri.file(config.bin, windows: Platform.isWindows),
    config.binArgs,
    null)
  .then((Isolate i) {
    getFileChanges(config.baseDir, extList: config.extList)
    .then((list) {
      AnsiPen pen = new AnsiPen()
      ..yellow(bold: true);
      print('${pen("looking yellow")}');
    });
    //    kill watch and isolate. startIsolate()

  });
}
