import 'dart:io';
import 'dart:async';

import 'package:watcher/watcher.dart';

import 'package:revolver/revolver.dart' as revolver;

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

bool _isRequestedExtension(String filePath, {List<String> requestedExtensions}) {

  // Default to returning everything or if this is a directory
  if (requestedExtensions == null || requestedExtensions.length == 0 ||
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

Stream<revolver.RevolverEvent> getFileChanges({String path, List<String> extList, bool usePolling: false}) {
  Directory dir = null;

  if (path?.length > 0) {
   dir = new Directory(path);
  }
  else {
    dir = Directory.current;
  }

  if (usePolling) {
    return new DirectoryWatcher(dir.path).events
      .where((WatchEvent evt) => _isRequestedExtension(evt.path, requestedExtensions: extList))
      .map((WatchEvent evt) => new revolver.RevolverEvent.fromWatchEvent(evt));
  }

  StreamController<revolver.RevolverEvent> streamController = new StreamController<revolver.RevolverEvent>();

  // Linux doesn't support the recursive directory watch. This method
  // should catch all platforms
  dir.list(recursive: true, followLinks: true)
    .where((FileSystemEntity entity) {
      FileStat stat = entity.statSync();
      return stat.type == FileSystemEntityType.DIRECTORY;
    })
    .map((FileSystemEntity entity) => entity as Directory)
    .listen((Directory dir) {

      DirectorWatcher dirWatcher = new DirectorWatcher(dir);

      dirWatcher.stream
      .where((revolver.RevolverEvent evt) => streamController.hasListener)
      .where((revolver.RevolverEvent evt) => _isRequestedExtension(evt.filePath, requestedExtensions: extList))
      .listen((revolver.RevolverEvent evt) => streamController.add(evt));
    });

    return streamController.stream;
}
