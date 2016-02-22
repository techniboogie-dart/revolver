import 'dart:isolate';
import 'dart:async';

import 'package:revolver/src/file_watcher.dart';
import 'package:revolver/src/messaging.dart';
import 'package:revolver/revolver.dart' as revolver;

/// Manages the reloading of the of the application isolate.
Future startTimer(SendPort sender, {String baseDir, List<String> extList, int reloadDelayMs, bool usePolling}) async {
  Duration _quietTime = new Duration(milliseconds: reloadDelayMs);
  Timer quietTimeCheck = null;
  // Track files, only show each file once between resets
  Set<String> fileList = new Set<String>();

  await for (revolver.RevolverEvent evt in getFileChanges(path: baseDir, extList: extList, usePolling: usePolling)) {
    String filePath = evt.filePath;

    if (!fileList.contains(filePath)) {
      printEvent(evt);
      fileList.add(evt.filePath);
    }

    // Cancel Timer and create a new one
    quietTimeCheck?.cancel();
    quietTimeCheck = new Timer(_quietTime, () {
      sender.send(revolver.RevolverAction.reload);
      fileList.clear();
    });
  }
}
