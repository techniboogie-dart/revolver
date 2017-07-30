import 'dart:io';
import 'dart:async';

import 'package:watcher/watcher.dart';

import 'package:revolver/revolver.dart' as revolver;
import 'package:revolver/src/file_filter.dart';

/// A wrapper around a [StreamController].
class DirectorWatcher {
  StreamController<revolver.RevolverEvent> _streamController;

  DirectorWatcher(Directory dir) {
    _streamController = new StreamController<revolver.RevolverEvent>();

    _watch(dir);
  }

  void _watch(Directory dir) {

    dir.watch(events: FileSystemEvent.ALL)
    .listen((FileSystemEvent evt) {
      // Watch new directories
      if (evt.isDirectory && evt.type == FileSystemEvent.CREATE) {
        _watch(new Directory(evt.path));
      }

      _streamController.add(new revolver.RevolverEvent.fromFileSystemEvent(evt));
    });
  }

  Stream<revolver.RevolverEvent> get stream => _streamController.stream;
}

/// Streams all non-filtered [RevolverEvent].
Stream<revolver.RevolverEvent> getFileChanges() {
  String baseDir = revolver.RevolverConfiguration.baseDir;
  bool usePolling = revolver.RevolverConfiguration.usePolling;

  Directory dir = null;

  if (baseDir?.length > 0) {
    dir = new Directory(baseDir);
  }
  else {
    dir = Directory.current;
  }

  if (usePolling) {
    return new DirectoryWatcher(dir.path).events
      .where((WatchEvent evt) => checkDoWatchFile(evt.path))
      .map((WatchEvent evt) => new revolver.RevolverEvent.fromWatchEvent(evt));
  }

  StreamController<revolver.RevolverEvent> streamController = new StreamController<revolver.RevolverEvent>();

  watchDirectory(dir, streamController);

  // Linux doesn't support the recursive directory watch. This method
  // should catch all platforms
  dir.list(recursive: true, followLinks: true)
    .where((FileSystemEntity entity) {
      FileStat stat = entity.statSync();
      return stat.type == FileSystemEntityType.DIRECTORY;
    })
    .map((FileSystemEntity entity) => entity as Directory)
    .listen((Directory dir) {
      watchDirectory(dir, streamController);
    });

    return streamController.stream;
}

void watchDirectory(Directory dir, StreamController sharedStreamController) {

  DirectorWatcher dirWatcher = new DirectorWatcher(dir);

  dirWatcher.stream
  .where((revolver.RevolverEvent evt) => sharedStreamController.hasListener)
  .where((revolver.RevolverEvent evt) => checkDoWatchFile(evt.filePath))
  .listen((revolver.RevolverEvent evt) => sharedStreamController.add(evt));
}
