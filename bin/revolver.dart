import 'package:revolver/revolver.dart' as revolver;
import 'dart:io';
import 'package:watcher/watcher.dart';

import 'dart:async';

void main(List<String> args) {
  //baseDir fileTypes bin args
  // String entry = args[0];

  revolver.start(new revolver.Configuration('.', ['dart'], '../test/main.dart', ['hello']));

  print('here we go!');

}
