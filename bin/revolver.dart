import 'dart:io';

import 'package:args/args.dart';

import 'package:revolver/revolver.dart' as revolver;

void main(List<String> args) {
  ArgParser parser = new ArgParser();
  parser.addOption('ext', abbr: 'e', defaultsTo: null, help: 'Watch only the specified extensions.');
  parser.addFlag('use-polling', abbr: 'p', negatable: false, defaultsTo: false, help: 'Using file polling, rather than file system events, to detect file changes.');
  parser.addFlag('help', abbr: 'h', negatable: false, defaultsTo: false, help: 'Displays this help information.');
  parser.addFlag('git', abbr: 'g', negatable: false, defaultsTo: false, help: 'Git project. Ignores git files and respects the contents of .gitignore.');
  parser.addFlag('ignore-dart', abbr: 'd', negatable: true, defaultsTo: true, help: 'Ignore dart project files.');

  ArgResults results = parser.parse(args);

  if (results['help'] || results.rest.length == 0) {
    print(parser.usage);

    return;
  }

  String bin = results.rest[0];
  List<String> params = results.rest.getRange(1, results.rest.length).toList();

  File binFile = new File(bin);

  if (!binFile.isAbsolute) {
    bin = Directory.current.path + Platform.pathSeparator + bin;
  }

  revolver.RevolverConfiguration.initialize(
    bin,
    binArgs: params,
    baseDir: Directory.current.path,
    extList: results['ext']?.split(',')?.map((value) => value.trim()),
    usePolling: results['use-polling'],
    isGitProject: results['git'],
    doIgnoreDart: results['ignore-dart']
  );

  revolver.start();
}
